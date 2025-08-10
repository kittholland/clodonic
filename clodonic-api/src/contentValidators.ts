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
    // Extract YAML frontmatter (everything before first ---)
    let yamlContent = content;
    const yamlEnd = content.indexOf('\n---');
    if (yamlEnd !== -1) {
      yamlContent = content.slice(0, yamlEnd);
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
        // Simple string format like "Read, Edit, Bash"
        const tools = agent.tools.split(',').map((t: string) => t.trim());
        const validTools = ['Read', 'Edit', 'Write', 'Bash', 'Grep', 'Glob', 'Task'];
        const invalidTools = tools.filter((t: string) => !validTools.includes(t));
        
        if (invalidTools.length > 0) {
          warnings.push(`Unknown tools: ${invalidTools.join(', ')}`);
        }
      } else if (Array.isArray(agent.tools)) {
        // Array format
        const validTools = ['Read', 'Edit', 'Write', 'Bash', 'Grep', 'Glob', 'Task'];
        const invalidTools = agent.tools.filter((t: any) => typeof t === 'string' && !validTools.includes(t));
        
        if (invalidTools.length > 0) {
          warnings.push(`Unknown tools: ${invalidTools.join(', ')}`);
        }
      }
    }
    
    // System prompt validation (everything after YAML frontmatter)
    const systemPromptStart = content.indexOf('\n---\n');
    if (systemPromptStart === -1) {
      warnings.push('No system prompt found after YAML frontmatter');
    } else {
      const systemPrompt = content.slice(systemPromptStart + 5).trim();
      if (!systemPrompt) {
        warnings.push('System prompt appears to be empty');
      } else if (systemPrompt.length < 10) {
        warnings.push('System prompt is very short');
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
 * Validates Hook shell script syntax and safety
 */
export function validateHook(content: string): ValidationResult {
  const warnings: string[] = [];
  
  // Basic shell syntax checks
  const syntaxErrors: string[] = [];
  
  // Check for unmatched quotes
  const singleQuotes = (content.match(/'/g) || []).length;
  const doubleQuotes = (content.match(/"/g) || []).length;
  
  if (singleQuotes % 2 !== 0) {
    syntaxErrors.push('Unmatched single quotes');
  }
  if (doubleQuotes % 2 !== 0) {
    syntaxErrors.push('Unmatched double quotes'); 
  }
  
  // Check for unmatched brackets/parentheses
  const opens = (content.match(/\(/g) || []).length;
  const closes = (content.match(/\)/g) || []).length;
  if (opens !== closes) {
    syntaxErrors.push('Unmatched parentheses');
  }
  
  // Check for hanging operators
  if (/\|\s*$|&&\s*$|\|\|\s*$/.test(content)) {
    syntaxErrors.push('Hanging pipe or logical operator');
  }
  
  if (syntaxErrors.length > 0) {
    return { valid: false, error: `Shell syntax errors: ${syntaxErrors.join(', ')}` };
  }
  
  // Best practice warnings
  if (!content.includes('#!/bin/bash') && !content.includes('#!/bin/sh')) {
    warnings.push('Missing shebang line');
  }
  
  if (content.includes('$1') && !content.includes('$@') && !content.includes('"$1"')) {
    warnings.push('Unquoted variable usage - consider using "$1"');
  }
  
  // Exit code validation for Claude Code hooks
  if (!content.includes('exit ')) {
    warnings.push('Hook should explicitly exit with status code (exit 0 for success, exit 2 to block)');
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