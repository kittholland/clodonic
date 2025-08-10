import { getLogger } from './logger';
import type { Context } from 'hono';

export interface ValidationResult {
  status: 'BLOCK' | 'WARN' | 'ALLOW';
  reason?: string;
  category?: string;
}

// Patterns that auto-reject submissions
const BLOCK_PATTERNS = {
  spam: [
    // Only block obvious promotional spam, not educational mentions
    /BUY\s+NOW.*(?:CLICK|MONEY|FREE).*(?:URGENT|LIMITED|TODAY)/i, // Multi-keyword spam
    /MAKE\s+\$\d+.*(?:TODAY|FAST|EASY|GUARANTEED)/i,              // Money-making schemes
    /🔥{3,}.*💰.*🚀|💰{3,}.*🔥.*🚀/  // Excessive emoji combinations
  ],
  
  malicious_instructions: [
    // Direct instructions for clearly harmful actions (regardless of type)
    /(?:please|now|help\s+me).*(?:delete|wipe|destroy).*(?:entire|all|everything).*(?:system|computer|files)/i,
    /(?:use|run).*(?:malware|virus|trojan|ransomware|keylogger)/i,
    /(?:steal|extract|exfiltrate).*(?:passwords|credentials|private.*keys|personal.*data)/i,
    /(?:create|install|setup).*(?:backdoor|rootkit|botnet)/i
  ],
  
  gibberish: [
    /^(.)\1{15,}$/,           // Repeated single character
    /[^\w\s.,!?-]{15,}/,      // Too many symbols/special chars
    /^[A-Z\s!]{40,}$/,        // All caps shouting
    /^\s*$/                   // Empty only
  ],
  
  phishing: [
    // Only block actual requests for credentials, not educational content
    /(?:please|now|immediately)\s+enter\s+your\s+(password|credit|ssn)/i,
    /login\s+with\s+your\s+(github|google|account)\s+(?:now|here|below)/i,
    /click\s+(?:here|now|below)\s+to\s+(verify|confirm|login)/i
  ],
  
  malicious_urls: [
    // Only block obviously suspicious patterns, allow legitimate examples
    /https?:\/\/(bit\.ly|tinyurl)\/[a-z0-9]+.*(?:free|money|urgent)/i, // Suspicious shorteners with spam
    /https?:\/\/(?:(?!127\.0\.0\.1|localhost)[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}).*(?:download|install|free)/i,  // Suspicious IPs with actions
    /\.(?:tk|ml|ga|cf)\/.*(?:download|free|money)/i  // Suspicious TLDs with spam keywords
  ]
};

// Patterns that flag for user warning
const WARN_PATTERNS = {
  dangerous_shell: [
    // More context-aware dangerous command detection
    /(?<!(?:avoid|never|don't|prevent|block).*?)rm\s+-rf\s+(?!\/tmp\/safe|\/var\/tmp)/i,
    /(?<!(?:avoid|never|don't).*?)sudo\s+rm\s+-rf/i,
    /dd\s+if=\/dev\/(?!null)(?!zero)/i,
    /(?<!(?:avoid|never|don't|example|bad).*?)curl[^|]*\|\s*sh/i,
    /(?<!(?:avoid|never|don't|example|bad).*?)wget[^|]*\|\s*sh/i,
    /(?<!(?:avoid|never|don't).*?)eval\s*\([^)]*(?:input|user|request)/i,
    /(?<!(?:avoid|never|don't).*?)exec\s*\([^)]*(?:input|user|request)/i
  ],
  
  dangerous_instructions: [
    // Instructions that could lead Claude Code to take harmful actions
    /(?<!(?:never|don't|avoid|prevent).*?)(?:delete|remove)\s+(?:all|entire|everything).*(?:directory|folder|files?)/i,
    /(?<!(?:never|don't|avoid).*?)(?:run|execute).*rm\s+-rf/i,
    /(?<!(?:never|don't|avoid).*?)(?:use|run)\s+bash.*(?:delete|remove|wipe)/i,
    /(?<!(?:never|don't|avoid).*?)(?:download|fetch).*(?:pipe|\||execute).*(?:sh|bash)/i,
    /(?<!(?:never|don't|avoid).*?)(?:install|run).*(?:malware|virus|backdoor|keylogger)/i,
    /(?<!(?:never|don't|avoid).*?)(?:send|transmit|upload).*(?:sensitive|private|secret|password|key).*(?:data|information)/i,
    /(?<!(?:never|don't|avoid).*?)(?:access|read|steal).*(?:\/etc\/passwd|\/etc\/shadow|private.*key|credentials)/i
  ],
  
  sensitive_paths: [
    // Only warn if combined with access attempts, not just mentions
    /(?<!(?:avoid|protect|secure|block).*?)\/etc\/(?:passwd|shadow)(?!.*(?:safe|example|demo))/i,
    /(?<!(?:avoid|protect|secure).*?)\/home\/[^\/]*\/\.ssh(?!.*(?:example|demo))/i,
    /(?<!(?:avoid|protect|secure).*?)~\/\.(?:aws|docker)(?!.*(?:safe|example|demo))/i,
    /\/var\/log\/.*\.log.*(?:cat|tail|head|grep)/i  // Only warn when actually accessing logs
  ],
  
  network_access: [
    // Allow development references, only warn for suspicious network activity
    /(?<!(?:dev|development|local|test).*?)(?:localhost|127\.0\.0\.1):\d+.*(?:curl|wget|nc|netcat)/i,
    /192\.168\.\d+\.\d+.*(?:ssh|scp|rsync)(?!.*(?:backup|sync|deploy))/i,  // Private IP access without legitimate purpose
    /(?<!(?:avoid|example).*?)nc\s+-[a-z]*l.*(?:shell|backdoor)/i  // Netcat listeners with suspicious intent
  ],
  
  secrets_handling: [
    // Only warn for actual credentials, not just mentions of security concepts
    /(?:password|secret|token)\s*=\s*["'][^"']{8,}["']/i,  // Actual credential assignments
    /(?<!(?:example|demo|test|placeholder).*?)(?:api_key|private_key|client_secret)\s*[:=]\s*["'][^"']{10,}["']/i,
    /(?<!(?:example|demo|safe).*?)\.env.*(?:AWS|API|SECRET|KEY)(?!.*(?:example|demo))/i  // Real env vars, not examples
  ],
  
  data_exfil: [
    // Only flag suspicious data transmission patterns
    /base64\s+[A-Za-z0-9+\/]{20,}\s*\|\s*curl.*(?:http|ftp)/i,  // Encoded data being sent
    /curl\s+-X\s+POST.*--data.*(?:password|token|key|secret)/i,  // Posting sensitive data
    /wget.*--post-data.*\$\(.*\)|wget.*--post-data.*`.*`/i  // Dynamic data posting
  ]
};

export function validateContent(
  content: string, 
  type: string, 
  title: string, 
  description: string,
  c: Context
): ValidationResult {
  const logger = getLogger(c);
  const fullText = `${title} ${description} ${content}`.toLowerCase();
  
  // BLOCK: Check for obvious spam/scam/trolling and malicious instructions
  for (const [category, patterns] of Object.entries(BLOCK_PATTERNS)) {
    for (const pattern of patterns) {
      if (pattern.test(fullText) || pattern.test(content)) {
        logger.warn('Content blocked', { 
          category, 
          pattern: pattern.source,
          type,
          contentPreview: content.substring(0, 100)
        });
        return {
          status: 'BLOCK',
          reason: getBlockMessage(category),
          category
        };
      }
    }
  }
  
  // WARN: Check for potentially dangerous patterns
  const warnings: string[] = [];
  
  // Check for protective/educational context that reduces warnings
  const isProtective = /(?:prevent|protect|safe|validate|security|block|avoid|example|demo|tutorial|learn|educational|how\s+to\s+(?:avoid|prevent)|never\s+(?:do|use|run)|don't\s+(?:do|use|run))/i.test(fullText);
  
  // Extra strict checking for instructional content types
  const isInstructional = ['prompt', 'claude_md', 'agent'].includes(type);
  
  // Type-specific warnings with context awareness
  if (type === 'hook') {
    warnings.push(...checkPatterns(content, WARN_PATTERNS.dangerous_shell, 'dangerous shell commands'));
    warnings.push(...checkPatterns(content, WARN_PATTERNS.sensitive_paths, 'sensitive file access'));
  }
  
  if (type === 'command') {
    // More lenient for commands since they're documented workflows
    const bashPatterns = /Bash\([^)]*rm\s+-rf[^)]*\)|!\s*`[^`]*rm\s+-rf[^`]*`/i;
    if (bashPatterns.test(content) && !isProtective) {
      warnings.push('contains file deletion commands');
    }
  }
  
  // Instructional content can be just as dangerous - check prompts, CLAUDE.md, agents
  if (['prompt', 'claude_md', 'agent'].includes(type)) {
    warnings.push(...checkPatterns(fullText, WARN_PATTERNS.dangerous_instructions, 'dangerous instructions'));
    warnings.push(...checkPatterns(fullText, WARN_PATTERNS.dangerous_shell, 'shell command instructions'));
  }
  
  // Universal warnings (all types) - only check if not already protective context
  if (!isProtective) {
    warnings.push(...checkPatterns(fullText, WARN_PATTERNS.network_access, 'suspicious network access'));
    warnings.push(...checkPatterns(fullText, WARN_PATTERNS.secrets_handling, 'credential handling'));
    warnings.push(...checkPatterns(content, WARN_PATTERNS.data_exfil, 'potential data transmission'));
  }
  
  
  // Apply warnings based on content type and context
  if (warnings.length > 0) {
    // For instructional content, be more strict unless clearly protective
    const shouldWarn = isInstructional ? !isProtective : !isProtective;
    
    if (shouldWarn) {
      logger.info('Content flagged with warnings', { 
        warnings, 
        type,
        isProtective,
        isInstructional,
        contentPreview: content.substring(0, 100)
      });
      
      const warningPrefix = isInstructional ? 
        'Contains instructions for potentially dangerous actions: ' :
        'Contains potentially dangerous patterns: ';
      
      return {
        status: 'WARN',
        reason: `${warningPrefix}${warnings.join(', ')}`,
        category: isInstructional ? 'instruction_warning' : 'security_warning'
      };
    }
  }
  
  // ALLOW: Everything else passes through
  logger.info('Content validation passed', { type, hasWarnings: warnings.length > 0, isProtective });
  return {
    status: 'ALLOW'
  };
}

function checkPatterns(text: string, patterns: RegExp[], description: string): string[] {
  const warnings: string[] = [];
  for (const pattern of patterns) {
    if (pattern.test(text)) {
      warnings.push(description);
      break; // Only add each category once
    }
  }
  return warnings;
}

function getBlockMessage(category: string): string {
  switch (category) {
    case 'spam':
      return 'Content appears to be spam or promotional material';
    case 'gibberish':
      return 'Content appears to be low-quality or gibberish';
    case 'phishing':
      return 'Content contains suspicious requests for personal information';
    case 'malicious_urls':
      return 'Content contains suspicious or potentially malicious URLs';
    case 'malicious_instructions':
      return 'Content contains instructions that could lead to harmful actions';
    default:
      return 'Content violates community guidelines';
  }
}