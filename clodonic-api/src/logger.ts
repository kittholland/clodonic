import { Context } from 'hono';

export interface LogContext {
  requestId?: string;
  userId?: string;
  method?: string;
  path?: string;
  ip?: string;
  userAgent?: string;
  duration?: number;
  error?: any;
  extra?: Record<string, any>;
}

export class Logger {
  private context: Context;
  private requestId: string;
  private startTime: number;

  constructor(context: Context) {
    this.context = context;
    this.requestId = crypto.randomUUID().slice(0, 8);
    this.startTime = Date.now();
  }

  private getBaseContext(): LogContext {
    return {
      requestId: this.requestId,
      method: this.context.req.method,
      path: this.context.req.path,
      ip: this.context.req.header('CF-Connecting-IP') || 
          this.context.req.header('X-Forwarded-For') || 
          'unknown',
      userAgent: this.context.req.header('User-Agent'),
    };
  }

  info(message: string, extra?: Record<string, any>) {
    const logData = {
      level: 'INFO',
      message,
      ...this.getBaseContext(),
      extra,
      timestamp: new Date().toISOString(),
    };
    console.log(JSON.stringify(logData));
  }

  warn(message: string, extra?: Record<string, any>) {
    const logData = {
      level: 'WARN',
      message,
      ...this.getBaseContext(),
      extra,
      timestamp: new Date().toISOString(),
    };
    console.warn(JSON.stringify(logData));
  }

  error(message: string, error?: any, extra?: Record<string, any>) {
    const logData = {
      level: 'ERROR',
      message,
      ...this.getBaseContext(),
      error: error ? {
        message: error.message,
        stack: error.stack,
        name: error.name,
      } : undefined,
      extra,
      timestamp: new Date().toISOString(),
    };
    console.error(JSON.stringify(logData));
  }

  metric(name: string, value: number, unit: string = 'ms', extra?: Record<string, any>) {
    const logData = {
      level: 'METRIC',
      metric: name,
      value,
      unit,
      ...this.getBaseContext(),
      extra,
      timestamp: new Date().toISOString(),
    };
    console.log(JSON.stringify(logData));
  }

  requestComplete(status: number, extra?: Record<string, any>) {
    const duration = Date.now() - this.startTime;
    const logData = {
      level: status >= 500 ? 'ERROR' : status >= 400 ? 'WARN' : 'INFO',
      message: 'Request completed',
      ...this.getBaseContext(),
      status,
      duration,
      extra,
      timestamp: new Date().toISOString(),
    };
    
    // Only log non-200 responses or slow requests
    if (status !== 200 || duration > 1000) {
      console.log(JSON.stringify(logData));
    }
  }
}

// Middleware to attach logger to context
export function loggerMiddleware() {
  return async (c: Context, next: () => Promise<void>) => {
    const logger = new Logger(c);
    c.set('logger', logger);
    
    try {
      await next();
      // Log request completion for non-asset requests
      if (!c.req.path.match(/\.(js|css|html|png|jpg|ico)$/)) {
        logger.requestComplete(c.res.status);
      }
    } catch (error) {
      logger.error('Unhandled error in request', error);
      logger.requestComplete(500);
      throw error;
    }
  };
}

// Helper to get logger from context
export function getLogger(c: Context): Logger {
  return c.get('logger') || new Logger(c);
}