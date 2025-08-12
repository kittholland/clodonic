import { McpAgent } from "agents/mcp";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";

// Pattern types
type PatternType = "claude_md" | "agent" | "prompt" | "hook" | "command";

interface Pattern {
	id: number;
	title: string;
	description: string;
	content: string;
	type: PatternType;
	votes_up: number;
	votes_down: number;
	submitter_name: string;
	created_at: string;
	tags: any[]; // Can be strings or objects
}

// Icons for visual hierarchy
const ICONS: Record<PatternType, string> = {
	claude_md: "📝",
	agent: "🤖",
	prompt: "💬",
	hook: "🪝",
	command: "⚡",
};

// Define our MCP agent with tools
export class ClodonicMCP extends McpAgent {
	server = new McpServer({
		name: "Clodonic Pattern Repository",
		version: "2.1.1",
	});

	private apiUrl = "https://clodonic.ai/api";

	async init() {
		// Search patterns tool
		this.server.tool(
			"clodonic_search_patterns",
			{
				query: z.string().describe("Search query (e.g., 'Rails testing', 'parallel tasks')"),
				type: z.enum(["claude_md", "agent", "prompt", "hook", "command"]).optional()
					.describe("Filter by pattern type (optional)"),
			},
			async ({ query, type }) => {
				try {
					// Input validation to prevent abuse
					if (query.length > 200) {
						return {
							content: [{
								type: "text",
								text: "❌ Search query too long (max 200 characters)"
							}],
						};
					}
					
					// Sanitize query to prevent injection attempts
					const sanitizedQuery = query.replace(/[<>'"]/g, '');
					
					const params = new URLSearchParams({ q: sanitizedQuery });
					if (type) params.set("type", type);

					const response = await fetch(`${this.apiUrl}/search?${params}`, {
						headers: {
							"User-Agent": "Clodonic-MCP/2.0.0",
							Accept: "application/json",
						},
					});

					if (!response.ok) {
						return {
							content: [{
								type: "text",
								text: `❌ Search failed: ${response.statusText}\n\nTry browsing patterns at https://clodonic.ai`,
							}],
						};
					}

					const data = await response.json();
					// Limit results to prevent memory abuse
					const results = data.results?.slice(0, 10) || [];

					if (results.length === 0) {
						return {
							content: [{
								type: "text",
								text: `No patterns found for "${query}".\n\n💡 Try:\n• Different keywords\n• Browse at https://clodonic.ai\n• Submit your own pattern`,
							}],
						};
					}

					const patterns = results
						.map((p: Pattern) => {
							const icon = ICONS[p.type] || "📄";
							const author = p.submitter_name === 'clodonic-system' ? 'Clodonic Team' : (p.submitter_name || "Anonymous");
							const votes = p.votes_up - p.votes_down;
							const tags = this.formatTags(p.tags);
							const slug = this.slugify(p.title);

							return `${icon} **${p.title}**\n   Author: @${author} | Type: ${p.type} | ⭐ ${votes} votes\n   ${p.description}${tags ? `\n   Tags: ${tags}` : ""}\n   💬 Install: \`install pattern ${p.id} from clodonic\` or use slug: ${slug}`;
						})
						.join("\n\n");

					return {
						content: [{
							type: "text",
							text: `Found ${results.length} patterns for "${query}":\n\n${patterns}\n\n💡 Use pattern ID or slug to install.`,
						}],
					};
				} catch (error) {
					return {
						content: [{ type: "text", text: `❌ Search failed: ${error.message}` }],
					};
				}
			},
		);

		// Get pattern details tool
		this.server.tool(
			"clodonic_get_pattern",
			{
				patternId: z.number().int().positive().describe("Pattern ID from search results"),
			},
			async ({ patternId }) => {
				try {
					// Validate pattern ID to prevent enumeration attacks
					if (patternId < 1 || patternId > 100000) {
						return {
							content: [{
								type: "text",
								text: `❌ Invalid pattern ID: ${patternId}`
							}],
						};
					}
					
					const response = await fetch(`${this.apiUrl}/items/${patternId}`, {
						headers: {
							"User-Agent": "Clodonic-MCP/2.0.0",
							Accept: "application/json",
						},
					});

					if (!response.ok) {
						if (response.status === 404) {
							return {
								content: [{
									type: "text",
									text: `❌ Pattern ${patternId} not found.\n\nTry searching first:\n\`search for patterns on clodonic\`\n\nOr browse at https://clodonic.ai`,
								}],
							};
						}
						return {
							content: [{ type: "text", text: `❌ Failed to get pattern: ${response.statusText}` }],
						};
					}

					const pattern: Pattern = await response.json();
					const icon = ICONS[pattern.type] || "📄";
					const author = pattern.submitter_name || "Anonymous";
					const votes = pattern.votes_up - pattern.votes_down;
					const tags = this.formatTags(pattern.tags);
					const slug = this.slugify(pattern.title);

					const info = [
						`${icon} **${pattern.title}** (ID: ${pattern.id})`,
						`Author: @${author} | Type: ${pattern.type}`,
						`Votes: ⭐ ${votes} (${pattern.votes_up} up, ${pattern.votes_down} down)`,
						`Created: ${new Date(pattern.created_at).toLocaleDateString()}`,
						tags ? `Tags: ${tags}` : "",
						`\nDescription: ${pattern.description}`,
						`\n**Content Preview:**`,
						`\`\`\`${this.getLanguageForType(pattern.type)}`,
						pattern.content.slice(0, 500) + (pattern.content.length > 500 ? "..." : ""),
						`\`\`\``,
						`\n💬 To install: \`install pattern ${pattern.id} from clodonic\``,
						`Slug: ${slug}`,
					]
						.filter(Boolean)
						.join("\n");

					return {
						content: [{ type: "text", text: info }],
					};
				} catch (error) {
					return {
						content: [{ type: "text", text: `❌ Failed to get pattern: ${error.message}` }],
					};
				}
			},
		);

		// Install pattern tool
		this.server.tool(
			"clodonic_install_pattern",
			{
				patternId: z.number().int().positive().describe("Pattern ID from search results"),
				dryRun: z.boolean().default(false).describe("Preview changes without applying"),
				strategy: z.enum(["merge", "replace", "append"]).default("append")
					.describe("How to handle existing content (for claude_md type)"),
			},
			async ({ patternId, dryRun, strategy }) => {
				try {
					// Validate pattern ID to prevent enumeration attacks
					if (patternId < 1 || patternId > 100000) {
						return {
							content: [{
								type: "text",
								text: `❌ Invalid pattern ID: ${patternId}`
							}],
						};
					}
					
					const response = await fetch(`${this.apiUrl}/items/${patternId}`, {
						headers: {
							"User-Agent": "Clodonic-MCP/2.0.0",
							Accept: "application/json",
						},
					});

					if (!response.ok) {
						if (response.status === 404) {
							return {
								content: [{
									type: "text",
									text: `❌ Pattern ${patternId} not found.\n\nSearch for patterns first:\n\`search for [topic] on clodonic\``,
								}],
							};
						}
						return {
							content: [{ type: "text", text: `❌ Failed to fetch pattern: ${response.statusText}` }],
						};
					}

					const pattern: Pattern = await response.json();
					const instructions = this.generateInstallInstructions(pattern, dryRun, strategy);

					return {
						content: [{ type: "text", text: instructions }],
					};
				} catch (error) {
					return {
						content: [{ type: "text", text: `❌ Installation failed: ${error.message}` }],
					};
				}
			},
		);
	}

	private formatTags(tags: any[]): string {
		if (!tags || tags.length === 0) return "";
		return tags
			.map(tag => {
				if (typeof tag === "string") return `#${tag}`;
				if (tag && typeof tag === "object" && tag.name) return `#${tag.name}`;
				return "";
			})
			.filter(Boolean)
			.join(" ");
	}

	private getLanguageForType(type: string): string {
		const languageMap: Record<string, string> = {
			claude_md: "markdown",
			agent: "yaml",
			prompt: "markdown",
			hook: "bash",
			command: "bash",
		};
		return languageMap[type] || "plaintext";
	}

	private generateInstallInstructions(pattern: Pattern, dryRun: boolean, strategy: string): string {
		const icon = ICONS[pattern.type] || "📄";
		const slug = this.slugify(pattern.title);
		const author = pattern.submitter_name || "Anonymous";
		const date = new Date().toISOString().split("T")[0];

		if (dryRun) {
			return this.generateDryRunPreview(pattern, icon, slug, author, date, strategy);
		}

		// Generate type-specific installation instructions
		switch (pattern.type) {
			case "prompt":
				return this.generatePromptInstructions(pattern, icon, slug);

			case "claude_md":
				return this.generateClaudeMdInstructions(pattern, icon, slug, author, date, strategy);

			case "agent":
				return this.generateAgentInstructions(pattern, icon, slug, date);

			case "command":
				return this.generateCommandInstructions(pattern, icon, slug, date);

			case "hook":
				return this.generateHookInstructions(pattern, icon, slug, date);

			default:
				return `❌ Unknown pattern type: ${pattern.type}`;
		}
	}

	private generateDryRunPreview(
		pattern: Pattern,
		icon: string,
		slug: string,
		author: string,
		date: string,
		strategy: string,
	): string {
		let preview = `${icon} **Preview Mode** - "${pattern.title}"\n\n`;
		preview += `This would install a ${pattern.type} pattern.\n\n`;

		switch (pattern.type) {
			case "claude_md":
				preview += `📁 Would append to: CLAUDE.md\n`;
				preview += `📝 Strategy: ${strategy}\n`;
				preview += `\n**Content to add:**\n\`\`\`markdown\n`;
				preview += `<!-- BEGIN CLODONIC: ${slug} (ID: ${pattern.id}) -->\n`;
				preview += `<!-- Installed: ${date} | Author: @${author} -->\n`;
				preview += pattern.content;
				preview += `\n<!-- END CLODONIC: ${slug} -->\n\`\`\``;
				break;

			case "agent":
				preview += `📁 Would create: .claude/agents/clodonic-${slug}.md\n`;
				preview += `📝 Would update: .claude/clodonic-manifest.json\n`;
				preview += `⚠️ Restart required after installation\n`;
				preview += `\n**Agent configuration:**\n\`\`\`yaml\n`;
				preview += `# Clodonic Pattern: ${pattern.id}\n# ${pattern.title}\n`;
				// Show parsed format
				if (!pattern.content.includes('\n---\n')) {
					// Parse and show what will be created
					let parsedName = `clodonic-${slug}`;
					let parsedDesc = pattern.description;
					let parsedInstructions = '';
					
					const lines = pattern.content.split('\n');
					let inInstructions = false;
					let instructions: string[] = [];
					
					for (const line of lines) {
						if (line.startsWith('name:')) {
							parsedName = line.substring(5).trim();
						} else if (line.startsWith('description:')) {
							parsedDesc = line.substring(12).trim();
						} else if (line.startsWith('instructions:')) {
							inInstructions = true;
							const afterColon = line.substring(13).trim();
							if (afterColon && afterColon !== '|') {
								instructions.push(afterColon);
							}
						} else if (inInstructions) {
							instructions.push(line.replace(/^  /, ''));
						}
					}
					
					if (instructions.length > 0) {
						parsedInstructions = instructions.join('\n').trim();
					}
					
					preview += `name: ${parsedName}\n`;
					preview += `description: ${parsedDesc}\n`;
					preview += `instructions: |\n  ${parsedInstructions.split('\n').join('\n  ')}`;
				} else {
					preview += pattern.content;
				}
				preview += `\n\`\`\``;
				break;

			case "prompt":
				preview += `💬 This prompt would be applied immediately to your current work.\n`;
				preview += `📁 Optionally save to: .claude/prompts/clodonic-${slug}.md\n`;
				preview += `\n**Prompt content:**\n\`\`\`markdown\n`;
				preview += pattern.content;
				preview += `\n\`\`\``;
				break;

			case "command":
				preview += `📁 Would create: .claude/commands/clodonic-${slug}.md\n`;
				preview += `📝 Would update: .claude/claude.json\n`;
				preview += `⚠️ Restart required after installation\n`;
				preview += `\n**Command content:**\n\`\`\`markdown\n`;
				preview += pattern.content;
				preview += `\n\`\`\``;
				break;

			case "hook":
				preview += `📝 Would update: .claude/settings.json\n`;
				preview += `⚠️ Restart required after installation\n`;
				preview += `\n**Hook configuration:**\n\`\`\`json\n`;
				let hookConfig;
				try {
					hookConfig = JSON.parse(pattern.content);
				} catch (e) {
					hookConfig = { command: pattern.content };
				}
				preview += JSON.stringify(hookConfig, null, 2) + `\n\`\`\``;
				break;
		}

		preview += `\n\nRun without \`dryRun: true\` to actually install.`;
		return preview;
	}

	private generatePromptInstructions(pattern: Pattern, icon: string, slug: string): string {
		return `${icon} **"${pattern.title}" Prompt**

**APPLY THIS METHODOLOGY IMMEDIATELY TO CURRENT CONTEXT:**

${pattern.content}

**Instructions for Claude:**
- Apply the above methodology to whatever task, problem, or context we were just discussing
- Follow the structure and approach outlined in the pattern
- Do not just acknowledge the pattern - actively use it to address the current situation
- If no current context exists, ask the user what they want you to apply this methodology to

**Optional:** Would you like me to save this for future reference?
If yes, I'll create: \`.claude/prompts/clodonic-${slug}.md\``;
	}

	private generateClaudeMdInstructions(
		pattern: Pattern,
		icon: string,
		slug: string,
		author: string,
		date: string,
		strategy: string,
	): string {
		const manifestEntry = this.generateManifestEntry(pattern, slug, date, ["CLAUDE.md"]);

		const claudeContent = `\n<!-- BEGIN CLODONIC: ${slug} (ID: ${pattern.id}) -->\n<!-- Installed: ${date} | Author: @${author} | Version: 1.0.0 -->\n${pattern.content}\n<!-- END CLODONIC: ${slug} -->\n`;

		return `${icon} **Installing "${pattern.title}" instructions**

**UPDATE CLAUDE.MD FILE NOW:**

**Step 1: Read existing CLAUDE.md** (if it exists)

**Step 2: Append this content to CLAUDE.md**
Strategy: ${strategy}
\`\`\`markdown${claudeContent}\`\`\`

**Step 3: Update manifest**
File: \`.claude/clodonic-manifest.json\`
${manifestEntry}

**Instructions will be active immediately** - no restart required.

Updating CLAUDE.md now...`;
	}

	private generateAgentInstructions(pattern: Pattern, icon: string, slug: string, date: string): string {
		const agentFile = `.claude/agents/clodonic-${slug}.md`;
		const manifestEntry = this.generateManifestEntry(pattern, slug, date, [agentFile]);

		// Parse agent content to extract name, description, and instructions
		let agentName = `clodonic-${slug}`;
		let agentDescription = pattern.description;
		let agentInstructions = pattern.content;
		let agentTools = "*";
		
		// Check if content is YAML format (our current format) or markdown with frontmatter
		if (pattern.content.includes('\n---\n')) {
			// Already in markdown format with frontmatter - use as is
			agentInstructions = pattern.content;
		} else {
			// Try to parse YAML format and extract fields
			try {
				// Simple YAML parsing for our agent format
				const lines = pattern.content.split('\n');
				let inInstructions = false;
				let instructions: string[] = [];
				
				for (const line of lines) {
					if (line.startsWith('name:')) {
						agentName = line.substring(5).trim();
					} else if (line.startsWith('description:')) {
						agentDescription = line.substring(12).trim();
					} else if (line.startsWith('tools:')) {
						agentTools = line.substring(6).trim() || "*";
					} else if (line.startsWith('instructions:')) {
						inInstructions = true;
						// Check if it's a single line or multiline
						const afterColon = line.substring(13).trim();
						if (afterColon && afterColon !== '|') {
							instructions.push(afterColon);
						}
					} else if (inInstructions) {
						// Collect instruction lines (remove leading spaces from YAML indent)
						instructions.push(line.replace(/^  /, ''));
					}
				}
				
				if (instructions.length > 0) {
					agentInstructions = instructions.join('\n').trim();
				}
			} catch (e) {
				// If parsing fails, use raw content as instructions
				agentInstructions = pattern.content;
			}
			
		}
		
		// Build final agent content
		let agentContent: string;
		if (pattern.content.includes('\n---\n')) {
			// Already properly formatted - use as is
			agentContent = pattern.content;
		} else {
			// Build proper markdown + frontmatter format from YAML
			agentContent = `---
name: ${agentName}
description: ${agentDescription}
tools: ${agentTools}
---

<!-- Clodonic Pattern: ${pattern.id} -->
<!-- Title: ${pattern.title} -->
<!-- Installed: ${date} -->
<!-- Source: https://clodonic.ai/patterns/${pattern.id} -->

${agentInstructions}`;
		}

		return `${icon} **Installing "${pattern.title}" agent**

**CREATE THESE FILES NOW:**

**Step 1: Ensure directory exists**
\`\`\`bash
mkdir -p ~/.claude/agents
\`\`\`

**Step 2: Create agent file**
File: \`${agentFile}\`
\`\`\`markdown
${agentContent.startsWith('---\n') ? agentContent : `---\n${agentContent}`}
\`\`\`

**Step 3: Update manifest**
File: \`.claude/clodonic-manifest.json\`
${manifestEntry}

⚠️ **Restart Required**
After installation:
1. Exit Claude Code: \`Ctrl+C\` (or \`Cmd+C\` on Mac)
2. Continue session: \`claude --continue\`

**How to use your new subagent:**
- Use the Task tool with \`subagent_type: "${agentName}"\` to invoke directly
- Claude may also automatically delegate when the task matches the agent's description
- The subagent operates in its own isolated context with specialized instructions
- You can request: "use the ${agentName} agent to..." and Claude will use the Task tool
- The agent will appear with its own color when invoked

**This is a TRUE Claude Code subagent** that can be invoked by name!

Creating these files now...`;
	}

	private generateCommandInstructions(pattern: Pattern, icon: string, slug: string, date: string): string {
		const commandFile = `.claude/commands/clodonic-${slug}.md`;
		const manifestEntry = this.generateManifestEntry(pattern, slug, date, [commandFile]);

		const commandContent = `<!-- Clodonic Pattern: ${pattern.id} -->
<!-- Title: ${pattern.title} -->
<!-- Installed: ${date} -->
<!-- Source: https://clodonic.ai/patterns/${pattern.id} -->

${pattern.content}`;

		return `${icon} **Installing "${pattern.title}" command**

**CREATE THESE FILES NOW:**

**Step 1: Create command file**
File: \`${commandFile}\`
\`\`\`markdown
${commandContent}
\`\`\`

**Step 2: Update manifest**
File: \`.claude/clodonic-manifest.json\`
${manifestEntry}

**Usage after installation:**
- Use with: \`/clodonic-${slug}\` or \`/${slug}\`
- Available immediately - no restart required
- Supports \`$ARGUMENTS\` for parameters

Creating these files now...`;
	}

	private generateHookInstructions(pattern: Pattern, icon: string, slug: string, date: string): string {
		// Parse the hook configuration from the pattern content
		let hookConfig;
		try {
			hookConfig = JSON.parse(pattern.content);
		} catch (e) {
			// Fallback for non-JSON hooks
			hookConfig = {
				hooks: [{
					type: "command",
					command: pattern.content
				}]
			};
		}

		// Extract event type from metadata or pattern
		const hookType = this.extractHookType(pattern);
		const manifestEntry = this.generateManifestEntry(pattern, slug, date, ["~/.claude/settings.json"]);

		return `${icon} **Installing "${pattern.title}" hook**

**UPDATE SETTINGS FILE NOW:**

**Step 1: Read existing settings**
File: \`~/.claude/settings.json\` (create if doesn't exist)

**Step 2: Add hook to "${hookType}" array**
Add this entry to the hooks.${hookType} array:
\`\`\`json
${JSON.stringify(hookConfig, null, 2)}
\`\`\`

**Step 3: Update manifest**
File: \`.claude/clodonic-manifest.json\`
${manifestEntry}

**Hook will trigger on:** ${hookType}
**Matcher:** ${hookConfig.matcher || "All tools (*)"}

Updating settings file now...`;
	}

	private generateManifestEntry(pattern: Pattern, slug: string, date: string, files: string[]): string {
		return `Read existing manifest (if exists) and merge this entry:
\`\`\`json
{
  "${slug}": {
    "id": ${pattern.id},
    "type": "${pattern.type}",
    "version": "1.0.0",
    "installed": "${date}T00:00:00Z",
    "files": ${JSON.stringify(files, null, 2).split("\n").join("\n    ")}
  }
}
\`\`\`
**Important**: If manifest exists, add this as a new key to the existing object. Don't replace the entire file.`;
	}

	private extractHookType(pattern: Pattern): string {
		// Try to extract from description or content
		const description = pattern.description.toLowerCase();
		const content = pattern.content.toLowerCase();
		
		// Check description first (more reliable)
		if (description.includes("pretooluse")) return "PreToolUse";
		if (description.includes("posttooluse")) return "PostToolUse";
		if (description.includes("userpromptsubmit")) return "UserPromptSubmit";
		if (description.includes("sessionstart")) return "SessionStart";
		if (description.includes("stop")) return "Stop";
		
		// Fallback to content analysis
		if (content.includes("pretooluse")) return "PreToolUse";
		if (content.includes("posttooluse")) return "PostToolUse";
		if (content.includes("userpromptsubmit")) return "UserPromptSubmit";
		if (content.includes("before") || content.includes("pre")) return "PreToolUse";
		if (content.includes("after") || content.includes("post")) return "PostToolUse";
		if (content.includes("prompt") || content.includes("submit")) return "UserPromptSubmit";
		
		return "PostToolUse"; // default - most common use case
	}

	private slugify(text: string): string {
		return text.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
	}
}

export default {
	fetch(request: Request, env: Env, ctx: ExecutionContext) {
		const url = new URL(request.url);

		// Legacy SSE endpoint (for backward compatibility)
		if (url.pathname === "/sse" || url.pathname === "/sse/message") {
			return ClodonicMCP.serveSSE("/sse").fetch(request, env, ctx);
		}

		// Modern Streamable HTTP endpoint (preferred)
		if (url.pathname === "/mcp" || url.pathname.startsWith("/mcp/")) {
			return ClodonicMCP.serve("/mcp").fetch(request, env, ctx);
		}

		// Health check
		if (url.pathname === "/health") {
			return new Response("OK", { status: 200 });
		}

		return new Response("Not found", { status: 404 });
	},
};