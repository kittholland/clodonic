import { z } from 'zod';

// Valid content types
const CONTENT_TYPES = ['claude_md', 'agent', 'prompt', 'hook', 'command'] as const;

// Content size limits per type (in characters)
const CONTENT_LIMITS = {
  claude_md: 10240,  // 10KB
  agent: 5120,       // 5KB  
  prompt: 500,       // 500 chars
  hook: 5120,        // 5KB
  command: 2048,     // 2KB
} as const;

// Metadata schema for pattern-specific properties
export const MetadataSchema = z.object({
  // Hook-specific
  eventType: z.enum([
    'PreToolUse', 
    'PostToolUse', 
    'UserPromptSubmit', 
    'Stop', 
    'SubagentStop', 
    'SessionStart', 
    'PreCompact', 
    'Notification'
  ]).optional(),
  
  // Agent-specific
  tools: z.array(z.string()).optional(),
  model: z.string().optional(),
  
  // Command-specific
  supportsArgs: z.boolean().optional(),
  environment: z.array(z.string()).optional(),
}).optional();

// Base submission schema
export const SubmissionSchema = z.object({
  type: z.enum(CONTENT_TYPES, {
    errorMap: () => ({ message: 'Invalid content type' })
  }),
  
  title: z.string()
    .trim()
    .min(1, 'Title is required')
    .max(200, 'Title cannot exceed 200 characters')
    .regex(/^[^<>&"']*$/, 'Title contains invalid characters'),
  
  description: z.string()
    .trim()
    .min(1, 'Description is required')
    .max(1000, 'Description cannot exceed 1000 characters'),
  
  content: z.string()
    .min(1, 'Content is required')
    .max(20480, 'Content too large'),
  
  tags: z.array(z.string().trim().min(1).max(50))
    .max(5, 'Maximum 5 tags allowed')
    .default([]),
  
  metadata: MetadataSchema
});

// Runtime content validation by type
export function validateContentByType(content: string, type: string): { valid: boolean; error?: string } {
  if (!CONTENT_TYPES.includes(type as any)) {
    return { valid: false, error: 'Invalid content type' };
  }
  
  const limit = CONTENT_LIMITS[type as keyof typeof CONTENT_LIMITS];
  if (content.length > limit) {
    return { valid: false, error: `Content exceeds ${limit} characters for ${type}` };
  }
  
  return { valid: true };
}

// Safe parsing with detailed error messages
export function parseSubmission(data: unknown) {
  try {
    const result = SubmissionSchema.parse(data);
    
    // Additional content-type specific validation
    const contentValidation = validateContentByType(result.content, result.type);
    if (!contentValidation.valid) {
      return {
        success: false as const,
        error: contentValidation.error!
      };
    }
    
    return {
      success: true as const,
      data: result
    };
  } catch (error) {
    if (error instanceof z.ZodError) {
      const firstError = error.errors[0];
      return {
        success: false as const,
        error: firstError?.message || 'Validation failed',
        field: firstError?.path?.join('.') || 'unknown'
      };
    }
    
    return {
      success: false as const,
      error: 'Invalid input format'
    };
  }
}

// Additional security schemas
export const TagNameSchema = z.string()
  .trim()
  .min(1)
  .max(50)
  .regex(/^[a-zA-Z0-9\-_]+$/, 'Tag contains invalid characters');

export const SearchQuerySchema = z.object({
  q: z.string().trim().min(1).max(200).optional(),
  type: z.enum(CONTENT_TYPES).optional(),
  tags: z.string().max(500).optional(), // Comma-separated tags
  sort: z.enum(['hot', 'top', 'new']).default('hot'),
  limit: z.coerce.number().min(1).max(100).default(30),
  offset: z.coerce.number().min(0).default(0),
  user: z.string().trim().max(50).optional(),
  timeframe: z.enum(['day', 'week', 'month', 'all']).optional()
});

export const VoteSchema = z.object({
  vote: z.union([z.literal(1), z.literal(-1)], {
    errorMap: () => ({ message: 'Vote must be 1 or -1' })
  })
});