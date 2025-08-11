const fs = require('fs');

// Read the SQL file
const sql = fs.readFileSync('seed-data-launch.sql', 'utf8');

// Check for common SQL syntax issues
const issues = [];

// Check for unescaped quotes in string literals
const lines = sql.split('\n');
let inString = false;
let stringDelimiter = '';
let currentStatement = '';

lines.forEach((line, lineNum) => {
  // Skip comments
  if (line.trim().startsWith('--')) return;
  
  currentStatement += line + '\n';
  
  // Check for unmatched quotes
  let quoteCount = (line.match(/'/g) || []).length;
  let escapedQuoteCount = (line.match(/\\'/g) || []).length;
  let doubleQuoteCount = (line.match(/''/g) || []).length;
  
  // Calculate actual unescaped quotes
  let actualQuotes = quoteCount - escapedQuoteCount - (doubleQuoteCount * 2);
  
  if (actualQuotes % 2 !== 0) {
    issues.push(`Line ${lineNum + 1}: Possible unmatched quote - "${line.trim()}"`);
  }
  
  // Check for problematic escape sequences
  if (line.includes("\\'")) {
    issues.push(`Line ${lineNum + 1}: Found \\' escape sequence (use '' for SQL escaping) - "${line.trim()}"`);
  }
  
  // Check for statement completeness
  if (line.includes(';')) {
    currentStatement = '';
  }
});

// Check specific problematic patterns
const problemPatterns = [
  { pattern: /I'm /g, message: "Unescaped apostrophe in I'm" },
  { pattern: /it's /g, message: "Unescaped apostrophe in it's" },
  { pattern: /don't /g, message: "Unescaped apostrophe in don't" },
  { pattern: /can't /g, message: "Unescaped apostrophe in can't" },
  { pattern: /won't /g, message: "Unescaped apostrophe in won't" },
];

problemPatterns.forEach(({ pattern, message }) => {
  let match;
  while ((match = pattern.exec(sql)) !== null) {
    const position = match.index;
    const lineNum = sql.substring(0, position).split('\n').length;
    issues.push(`Line ${lineNum}: ${message} at position ${position}`);
  }
});

// Report findings
if (issues.length > 0) {
  console.log('Found potential SQL syntax issues:\n');
  issues.forEach(issue => console.log('❌', issue));
  
  // Try to find the specific error at offset 2413
  console.log('\n📍 Checking around offset 2413:');
  const start = Math.max(0, 2413 - 50);
  const end = Math.min(sql.length, 2413 + 50);
  const context = sql.substring(start, end);
  console.log(`Characters ${start}-${end}:`);
  console.log(context.replace(/\n/g, '\\n'));
} else {
  console.log('✅ No obvious SQL syntax issues found');
}

// Check for the specific "near npm" error
const npmIndex = sql.indexOf('npm');
if (npmIndex !== -1) {
  console.log(`\n🔍 Found "npm" at offset ${npmIndex}:`);
  const context = sql.substring(Math.max(0, npmIndex - 30), Math.min(sql.length, npmIndex + 30));
  console.log(context);
}