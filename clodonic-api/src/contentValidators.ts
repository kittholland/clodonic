import * as yaml from 'js-yaml';

export interface ValidationResult {
  valid: boolean;
  error?: string;
  warnings?: string[];
}

/**
 * Validates Agent YAML structure and required fields
 */
export function validateAgent(content: string): ValidationResult {
  try {
    // Check if content has YAML frontmatter (markdown format) or is plain YAML
    const hasYamlFrontmatter = content.includes('\n---\n');
    let yamlContent = content;
    let systemPrompt = '';
    
    if (hasYamlFrontmatter) {
      // Extract YAML frontmatter (everything before ---) 
      const yamlEnd = content.indexOf('\n---');
      if (yamlEnd !== -1) {
        yamlContent = content.slice(0, yamlEnd);
        systemPrompt = content.slice(content.indexOf('\n---\n') + 5).trim();
      }
    }
    
    // Parse YAML
    const doc = yaml.load(yamlContent);
    
    if (!doc || typeof doc !== 'object') {
      return { valid: false, error: 'Agent must be valid YAML object' };
    }
    
    const agent = doc as any;
    const warnings: string[] = [];
    
    // Required fields
    if (!agent.name || typeof agent.name !== 'string') {
      return { valid: false, error: 'Agent must have a "name" field' };
    }
    
    if (!agent.description || typeof agent.description !== 'string') {
      return { valid: false, error: 'Agent must have a "description" field' };
    }
    
    // Validate name format
    if (!/^[a-zA-Z0-9\-_\s]+$/.test(agent.name)) {
      return { valid: false, error: 'Agent name contains invalid characters' };
    }
    
    // Tool validation (if specified)
    if (agent.tools) {
      if (typeof agent.tools === 'string') {
        // Check for wildcard first
        if (agent.tools === '*') {
          // Valid - all tools allowed
        } else {
          // Simple string format like "Read, Edit, Bash"
          const tools = agent.tools.split(',').map((t: string) => t.trim());
          const validTools = ['Read', 'Edit', 'Write', 'Bash', 'Grep', 'Glob', 'Task', 'MultiEdit', 'TodoWrite', 'WebFetch', 'WebSearch'];
          const invalidTools = tools.filter((t: string) => t !== '*' && !validTools.includes(t));
          
          if (invalidTools.length > 0) {
            warnings.push(`Unknown tools: ${invalidTools.join(', ')}`);
          }
        }
      } else if (Array.isArray(agent.tools)) {
        // Array format
        const validTools = ['Read', 'Edit', 'Write', 'Bash', 'Grep', 'Glob', 'Task', 'MultiEdit', 'TodoWrite', 'WebFetch', 'WebSearch'];
        const invalidTools = agent.tools.filter((t: any) => typeof t === 'string' && t !== '*' && !validTools.includes(t));
        
        if (invalidTools.length > 0) {
          warnings.push(`Unknown tools: ${invalidTools.join(', ')}`);
        }
      }
    }
    
    // System prompt or instructions validation
    if (hasYamlFrontmatter) {
      // Markdown format - check system prompt
      if (!systemPrompt) {
        warnings.push('System prompt appears to be empty');
      } else if (systemPrompt.length < 10) {
        warnings.push('System prompt is very short');
      }
    } else {
      // Plain YAML format - check for instructions field
      if (!agent.instructions) {
        warnings.push('No instructions field found in agent YAML');
      } else if (typeof agent.instructions !== 'string') {
        warnings.push('Instructions field should be a string');
      } else if (agent.instructions.length < 10) {
        warnings.push('Instructions are very short');
      }
    }
    
    return { valid: true, warnings: warnings.length > 0 ? warnings : undefined };
    
  } catch (error) {
    return { 
      valid: false, 
      error: `Invalid YAML: ${error instanceof Error ? error.message : 'Unknown error'}` 
    };
  }
}

/**
 * Validates Claude Code hook JSON structure
 */
export function validateHook(content: string): ValidationResult {
  const warnings: string[] = [];
  
  // First, try to parse as JSON
  let hookConfig: any;
  try {
    hookConfig = JSON.parse(content);
  } catch (error) {
    return { 
      valid: false, 
      error: 'Invalid JSON format. Hooks must be valid JSON configurations for Claude Code settings.json' 
    };
  }
  
  // Validate hook structure
  if (!hookConfig.hooks || !Array.isArray(hookConfig.hooks)) {
    return { 
      valid: false, 
      error: 'Hook must have a "hooks" array containing hook configurations' 
    };
  }
  
  // Check each hook in the array
  for (const hook of hookConfig.hooks) {
    if (!hook.type) {
      return { 
        valid: false, 
        error: 'Each hook must have a "type" field (usually "command")' 
      };
    }
    
    if (hook.type === 'command' && !hook.command) {
      return { 
        valid: false, 
        error: 'Command-type hooks must have a "command" field' 
      };
    }
  }
  
  // Validate matcher if present (for PreToolUse/PostToolUse hooks)
  if (hookConfig.matcher) {
    // Matcher should be a tool name or regex pattern
    if (typeof hookConfig.matcher !== 'string') {
      warnings.push('Matcher should be a string (tool name or regex pattern)');
    }
    
    // Common matchers
    const validMatchers = ['Bash', 'Write', 'Edit', 'MultiEdit', 'Read', 'Grep', 'Glob', '*'];
    const matcherPattern = hookConfig.matcher;
    
    // Check if it's a valid tool pattern
    if (!validMatchers.includes(matcherPattern) && !matcherPattern.includes('|')) {
      warnings.push(`Unusual matcher pattern: "${matcherPattern}". Common patterns: Bash, Write|Edit|MultiEdit, *`);
    }
  }
  
  // Check for metadata hints in description (not part of JSON but helpful)
  const contentLower = content.toLowerCase();
  let suggestedEventType = null;
  
  if (contentLower.includes('pretooluse') || contentLower.includes('before')) {
    suggestedEventType = 'PreToolUse';
  } else if (contentLower.includes('posttooluse') || contentLower.includes('after')) {
    suggestedEventType = 'PostToolUse';
  } else if (contentLower.includes('userpromptsubmit') || contentLower.includes('prompt')) {
    suggestedEventType = 'UserPromptSubmit';
  }
  
  if (suggestedEventType && hookConfig.matcher) {
    warnings.push(`This appears to be a ${suggestedEventType} hook based on content`);
  }
  
  // Validate command scripts if present
  for (const hook of hookConfig.hooks) {
    if (hook.type === 'command' && hook.command) {
      // Check for common issues in the command script
      const cmd = hook.command;
      
      if (!cmd.includes('#!/bin/bash') && !cmd.includes('#!/bin/sh')) {
        warnings.push('Command script should start with a shebang (#!/bin/bash)');
      }
      
      if (!cmd.includes('exit ')) {
        warnings.push('Hook command should explicitly exit with status code (exit 0 for success, exit 1 to block)');
      }
      
      if (cmd.includes('$CLAUDE_HOOK_PAYLOAD') && !cmd.includes('jq')) {
        warnings.push('Consider using jq to parse $CLAUDE_HOOK_PAYLOAD JSON');
      }
    }
  }
  
  return { valid: true, warnings: warnings.length > 0 ? warnings : undefined };
}

/**
 * Validates CLAUDE.md markdown structure
 */
export function validateClaudeMd(content: string): ValidationResult {
  const warnings: string[] = [];
  
  // Check for basic markdown structure
  if (!content.includes('#')) {
    warnings.push('No markdown headers found - consider adding structure');
  }
  
  // Check for common sections
  const commonSections = ['tech stack', 'project', 'command', 'workflow', 'style'];
  const lowerContent = content.toLowerCase();
  const missingSections = commonSections.filter(section => !lowerContent.includes(section));
  
  if (missingSections.length === commonSections.length) {
    warnings.push('Consider adding common sections like Tech Stack, Commands, or Workflow');
  }
  
  // Check for import syntax
  const importMatches = content.match(/@[a-zA-Z0-9\/\-._]+/g);
  if (importMatches && importMatches.length > 10) {
    warnings.push('Large number of imports detected - verify all paths are correct');
  }
  
  // Check for dangerous patterns in commands
  if (content.includes('rm -rf') && !content.toLowerCase().includes('never') && !content.toLowerCase().includes('avoid')) {
    warnings.push('Contains potentially dangerous commands without safety warnings');
  }
  
  return { valid: true, warnings: warnings.length > 0 ? warnings : undefined };
}

/**
 * Validates Command slash command format
 */
export function validateCommand(content: string): ValidationResult {
  const warnings: string[] = [];
  
  // Check for YAML frontmatter (optional)
  if (content.startsWith('---')) {
    const yamlEnd = content.indexOf('\n---\n', 3);
    if (yamlEnd === -1) {
      return { valid: false, error: 'Incomplete YAML frontmatter - missing closing ---' };
    }
    
    try {
      const yamlContent = content.slice(3, yamlEnd);
      const frontmatter = yaml.load(yamlContent);
      
      if (frontmatter && typeof frontmatter === 'object') {
        const fm = frontmatter as any;
        
        // Validate allowed-tools if present
        if (fm['allowed-tools']) {
          if (typeof fm['allowed-tools'] !== 'string') {
            warnings.push('allowed-tools should be a string');
          } else {
            // Check tool format: "Bash(git add:*), Read, Edit"
            const toolPattern = /^[\w\s,():\*\-]+$/;
            if (!toolPattern.test(fm['allowed-tools'])) {
              warnings.push('allowed-tools contains invalid characters');
            }
          }
        }
      }
    } catch (error) {
      return { valid: false, error: 'Invalid YAML frontmatter' };
    }
  }
  
  // Check for argument placeholders
  if (content.includes('$ARGUMENTS') && !content.toLowerCase().includes('task')) {
    warnings.push('Uses $ARGUMENTS but no clear task description found');
  }
  
  // Check for bash execution patterns
  if (content.includes('!`') || content.includes('!git') || content.includes('!npm')) {
    if (!content.includes('allowed-tools:')) {
      warnings.push('Contains bash execution but no tool restrictions defined');
    }
  }
  
  // Check for basic markdown structure
  if (!content.includes('##')) {
    warnings.push('Consider adding section headers (## Context, ## Task) for clarity');
  }
  
  return { valid: true, warnings: warnings.length > 0 ? warnings : undefined };
}

/**
 * Validates Prompt format and clarity
 */
export function validatePrompt(content: string): ValidationResult {
  const warnings: string[] = [];
  
  // Length checks
  if (content.length < 10) {
    return { valid: false, error: 'Prompt is too short to be useful' };
  }
  
  if (content.length > 400) {
    warnings.push('Long prompt - consider breaking into smaller, focused prompts');
  }
  
  // Check for placeholders
  if (content.includes('[') && content.includes(']') && !content.includes('$ARGUMENTS')) {
    warnings.push('Contains brackets [] - consider using $ARGUMENTS for dynamic content');
  }
  
  // Check for common prompt patterns
  if (!content.match(/(analyze|review|check|help|create|generate|explain)/i)) {
    warnings.push('Prompt may benefit from clearer action words (analyze, review, create, etc.)');
  }
  
  // Check for file references
  if (content.includes('@') && !content.includes('@filename')) {
    warnings.push('Contains @ symbol - ensure file references use proper @filename syntax');
  }
  
  return { valid: true, warnings: warnings.length > 0 ? warnings : undefined };
}

/**
 * Main content validation dispatcher
 */
export function validateContentStructure(content: string, type: string): ValidationResult {
  switch (type) {
    case 'agent':
      return validateAgent(content);
    case 'hook':
      return validateHook(content);
    case 'claude_md':
      return validateClaudeMd(content);
    case 'command':
      return validateCommand(content);
    case 'prompt':
      return validatePrompt(content);
    default:
      return { valid: true };
  }
}