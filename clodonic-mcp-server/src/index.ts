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
		version: "2.0.2",
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
					const params = new URLSearchParams({ q: query });
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
				preview += `📁 Would create: .claude/agents/clodonic-${slug}.yaml\n`;
				preview += `📝 Would update: .claude/claude.json\n`;
				preview += `⚠️ Restart required after installation\n`;
				preview += `\n**Agent configuration:**\n\`\`\`yaml\n`;
				preview += `# Clodonic Pattern: ${pattern.id}\n# ${pattern.title}\n`;
				preview += pattern.content;
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
				preview += `{\n  "id": "clodonic-${pattern.id}",\n`;
				preview += `  "command": "${pattern.content.replace(/"/g, '\\"')}",\n`;
				preview += `  "description": "${pattern.title}"\n}\n\`\`\``;
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

		return `${icon} **Installing "${pattern.title}" instructions**

I'll add this pattern to your CLAUDE.md file.

**Step 1: Check existing CLAUDE.md**
I'll verify if CLAUDE.md exists and check for any existing Clodonic patterns.

**Step 2: Append pattern to CLAUDE.md**
Strategy: ${strategy}
\`\`\`markdown
<!-- BEGIN CLODONIC: ${slug} (ID: ${pattern.id}) -->
<!-- Installed: ${date} | Author: @${author} | Version: 1.0.0 -->
${pattern.content}
<!-- END CLODONIC: ${slug} -->
\`\`\`

**Step 3: Update manifest**
File: \`.claude/clodonic-manifest.json\`
${manifestEntry}

I'll now create/update these files for you.`;
	}

	private generateAgentInstructions(pattern: Pattern, icon: string, slug: string, date: string): string {
		const manifestEntry = this.generateManifestEntry(pattern, slug, date, [
			`.claude/agents/clodonic-${slug}.yaml`,
		]);

		return `${icon} **Installing "${pattern.title}" agent package**

This will add a new agent capability to your Claude Code environment.

**Step 1: Create agent definition**
File: \`.claude/agents/clodonic-${slug}.yaml\`
\`\`\`yaml
# Clodonic Pattern: ${pattern.id}
# Title: ${pattern.title}
# Installed: ${date}
# Source: https://clodonic.ai/patterns/${pattern.id}

${pattern.content}
\`\`\`

**Step 2: Register agent in configuration**
File: \`.claude/claude.json\`
Add to "agents" section:
\`\`\`json
"clodonic-${slug}": {
  "type": "subagent",
  "description": "${pattern.description.replace(/"/g, '\\"')}",
  "config": ".claude/agents/clodonic-${slug}.yaml"
}
\`\`\`

**Step 3: Update manifest**
${manifestEntry}

I'll create these files now.

⚠️ **Restart Required**
After installation:
1. Exit Claude Code: \`Ctrl+C\` (or \`Cmd+C\` on Mac)
2. Continue session: \`claude --continue\`
3. Use your new agent: "delegate to clodonic-${slug}"`;
	}

	private generateCommandInstructions(pattern: Pattern, icon: string, slug: string, date: string): string {
		const manifestEntry = this.generateManifestEntry(pattern, slug, date, [
			`.claude/commands/clodonic-${slug}.md`,
		]);

		return `${icon} **Installing "${pattern.title}" command**

This will add a new slash command to your Claude Code environment.

**Step 1: Create command file**
File: \`.claude/commands/clodonic-${slug}.md\`
\`\`\`markdown
<!-- Clodonic Pattern: ${pattern.id} -->
<!-- Title: ${pattern.title} -->
<!-- Installed: ${date} -->

${pattern.content}
\`\`\`

**Step 2: Register command in configuration**
File: \`.claude/claude.json\`
Add to "commands" section:
\`\`\`json
"${slug}": {
  "description": "${pattern.description.replace(/"/g, '\\"')}",
  "file": ".claude/commands/clodonic-${slug}.md"
}
\`\`\`

**Step 3: Update manifest**
${manifestEntry}

I'll create these files now.

⚠️ **Restart Required**
After installation:
1. Exit Claude Code: \`Ctrl+C\` (or \`Cmd+C\` on Mac)
2. Continue session: \`claude --continue\`
3. Use your command: \`/${slug}\``;
	}

	private generateHookInstructions(pattern: Pattern, icon: string, slug: string, date: string): string {
		// Try to determine hook type from content or default to post-commit
		const hookType = this.extractHookType(pattern);
		const manifestEntry = this.generateManifestEntry(pattern, slug, date, []);

		return `${icon} **Installing "${pattern.title}" hook**

This will add an automated trigger to your Claude Code environment.

**Step 1: Update hooks configuration**
File: \`.claude/settings.json\`
Add to "hooks.${hookType}" array:
\`\`\`json
{
  "id": "clodonic-${pattern.id}",
  "command": "${pattern.content.replace(/"/g, '\\"').replace(/\n/g, "\\n")}",
  "description": "${pattern.title}"
}
\`\`\`

**Step 2: Update manifest**
${manifestEntry}

I'll update the settings file now.

⚠️ **Restart Required**
After installation:
1. Exit Claude Code: \`Ctrl+C\` (or \`Cmd+C\` on Mac)
2. Continue session: \`claude --continue\`
3. Hook will trigger automatically on: ${hookType}`;
	}

	private generateManifestEntry(pattern: Pattern, slug: string, date: string, files: string[]): string {
		return `\`\`\`json
{
  "${slug}": {
    "id": ${pattern.id},
    "type": "${pattern.type}",
    "version": "1.0.0",
    "installed": "${date}T00:00:00Z",
    "files": ${JSON.stringify(files, null, 2).split("\n").join("\n    ")}
  }
}
\`\`\``;
	}

	private extractHookType(pattern: Pattern): string {
		// Simple heuristic - could be improved with pattern metadata
		const content = pattern.content.toLowerCase();
		if (content.includes("commit")) return "post-commit";
		if (content.includes("push")) return "pre-push";
		if (content.includes("pull")) return "post-pull";
		return "post-commit"; // default
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