#!/usr/bin/env node

/**
 * shipyard.js — Weekly "Shipyard update" prompt generator (Reminders + GitHub)
 */

const { execSync, spawn } = require("child_process");
const fs = require("fs");
const path = require("path");

// For older Node.js versions that don't have fetch built-in
if (!globalThis.fetch) {
  try {
    // Try to use node-fetch if available
    const { default: fetch } = require("node-fetch");
    globalThis.fetch = fetch;
  } catch (e) {
    // If node-fetch is not available, we'll handle this in the sendToDeepSeek method
    globalThis.fetch = null;
  }
}

class ShipyardGenerator {
  constructor() {
    this.config = {
      since: "",
      until: "",
      lastWeek: false,
      showEmpty: false,
      copyToClipboard: false,
      enableReminders: true,
      enableGitHub: true,
      remindersList: "Work",
      remindersServer: "mcp-server-apple-reminders",
      outputFormat: "markdown",
      verbose: false,
      useAI: false,
      repos: [],
    };

    // Environment variables will be loaded after parsing args
    this.envVars = {};
  }

  // Load environment variables from .env.shipyard file
  loadEnvFile() {
    const envPath = path.join(__dirname, ".env.shipyard");
    const envVars = {};

    try {
      if (fs.existsSync(envPath)) {
        const envContent = fs.readFileSync(envPath, "utf8");

        // Parse each line of the .env file
        envContent.split("\n").forEach((line) => {
          const trimmedLine = line.trim();

          // Skip empty lines and comments
          if (!trimmedLine || trimmedLine.startsWith("#")) {
            return;
          }

          // Parse KEY=VALUE format
          const equalIndex = trimmedLine.indexOf("=");
          if (equalIndex > 0) {
            const key = trimmedLine.slice(0, equalIndex).trim();
            let value = trimmedLine.slice(equalIndex + 1).trim();

            // Remove quotes if present
            if (
              (value.startsWith('"') && value.endsWith('"')) ||
              (value.startsWith("'") && value.endsWith("'"))
            ) {
              value = value.slice(1, -1);
            }

            envVars[key] = value;
          }
        });

        // Successfully loaded
      }
    } catch (error) {
      // Silently fail - we'll handle missing API keys later
    }

    return envVars;
  }

  log(message) {
    if (this.config.verbose) {
      console.error(`INFO: ${message}`);
    }
  }

  error(message) {
    console.error(`ERROR: ${message}`);
    process.exit(1);
  }

  warning(message) {
    console.error(`WARNING: ${message}`);
  }

  // Parse command line arguments
  parseArgs(args) {
    for (let i = 0; i < args.length; i++) {
      const arg = args[i];

      switch (arg) {
        case "--since":
          this.config.since = args[++i] || "";
          break;
        case "--until":
          this.config.until = args[++i] || "";
          break;
        case "--last-week":
          this.config.lastWeek = true;
          break;
        case "--show-empty":
          this.config.showEmpty = true;
          break;
        case "--copy":
          this.config.copyToClipboard = true;
          break;
        case "--reminders":
          this.config.enableReminders = true;
          break;
        case "--no-reminders":
          this.config.enableReminders = false;
          break;
        case "--github":
          this.config.enableGitHub = true;
          break;
        case "--no-github":
          this.config.enableGitHub = false;
          break;
        case "--reminders-list":
          this.config.remindersList = args[++i] || "Work";
          break;
        case "--reminders-server":
          this.config.remindersServer =
            args[++i] || "mcp-server-apple-reminders";
          break;
        case "--format":
          this.config.outputFormat = args[++i] || "markdown";
          break;
        case "--verbose":
        case "-v":
          this.config.verbose = true;
          break;
        case "--ai":
          this.config.useAI = true;
          break;
        case "--help":
        case "-h":
          this.showHelp();
          process.exit(0);
        default:
          if (!arg.startsWith("--")) {
            this.config.repos.push(arg);
          }
          break;
      }
    }
  }

  showHelp() {
    console.log(`
Usage:
  node shipyard.js [OPTIONS] [<owner/repo | org>...]

Time Range Options:
  --last-week                    Use last week instead of current week
  --since YYYY-MM-DD[THH:MM]     Start date/time (default: Monday 00:01)
  --until YYYY-MM-DD[THH:MM]     End date/time (default: Sunday 23:59)

Data Source Options:
  --reminders                    Enable Apple Reminders (default: enabled)
  --no-reminders                 Disable Apple Reminders
  --github                       Enable GitHub activity (default: enabled if repos provided)
  --no-github                    Disable GitHub activity
  --reminders-list NAME          Reminders list name (default: "Work")
  --reminders-server NAME        MCP server name (default: "mcp-server-apple-reminders")

Output Options:
  --format FORMAT                Output format: markdown, slack (default: markdown)
  --copy                         Copy output to clipboard (macOS only)
  --show-empty                   Show sections even when empty
  --verbose, -v                  Show verbose output
  --ai                           Send prompt to DeepSeek AI for processing (requires .env.shipyard)

General Options:
  --help, -h                     Show this help message

Examples:
  # Basic usage - current week with both reminders and GitHub
  node shipyard.js my-org owner/repo

  # Only reminders, no GitHub
  node shipyard.js --no-github

  # Only GitHub for specific repos, no reminders
  node shipyard.js --no-reminders my-org owner/repo

  # Last week with custom reminders list
  node shipyard.js --last-week --reminders-list "Personal Tasks" my-org

  # Custom date range with Slack-friendly output
  node shipyard.js --since 2025-01-01 --until 2025-01-07 --format slack my-org

  # Copy to clipboard for immediate use
  node shipyard.js my-org --copy

  # Process with AI and copy AI response
  node shipyard.js my-org --ai --copy
`);
  }

  // Validate configuration
  validate() {
    // Validate output format
    if (!["markdown", "slack"].includes(this.config.outputFormat)) {
      this.error(
        `Invalid format '${this.config.outputFormat}'. Supported: markdown, slack`
      );
    }

    // Validate date formats
    const dateRegex = /^\d{4}-\d{2}-\d{2}(T\d{2}:\d{2})?$/;
    if (this.config.since && !dateRegex.test(this.config.since)) {
      this.error(
        `Invalid date format for --since: '${this.config.since}'. Use YYYY-MM-DD or YYYY-MM-DDTHH:MM`
      );
    }
    if (this.config.until && !dateRegex.test(this.config.until)) {
      this.error(
        `Invalid date format for --until: '${this.config.until}'. Use YYYY-MM-DD or YYYY-MM-DDTHH:MM`
      );
    }
  }

  // Calculate week range
  calculateWeekRange() {
    const now = new Date();
    const day = now.getDay();
    const mondayOffset = day === 0 ? -6 : 1 - day; // Sunday is 0, Monday is 1

    const monday = new Date(now);
    monday.setDate(now.getDate() + mondayOffset);

    const sunday = new Date(monday);
    sunday.setDate(monday.getDate() + 6);

    if (this.config.lastWeek) {
      monday.setDate(monday.getDate() - 7);
      sunday.setDate(sunday.getDate() - 7);
    }

    return {
      monday: monday.toISOString().split("T")[0],
      sunday: sunday.toISOString().split("T")[0],
    };
  }

  // Set up date range
  setupDateRange() {
    if (!this.config.since || !this.config.until) {
      const { monday, sunday } = this.calculateWeekRange();
      this.config.since = this.config.since || `${monday}T00:01`;
      this.config.until = this.config.until || `${sunday}T23:59`;
    }

    this.config.sinceDate = this.config.since.split("T")[0];
    this.config.untilDate = this.config.until.split("T")[0];
    this.config.dateRange = `${this.config.sinceDate}..${this.config.untilDate}`;
  }

  // Check if command exists
  commandExists(command) {
    try {
      execSync(`which ${command}`, { stdio: "ignore" });
      return true;
    } catch {
      return false;
    }
  }

  // Parse Apple Reminders date format "Aug  9, 2025 at 15:30" to Date object
  parseAppleReminderDate(dateStr) {
    if (!dateStr) return null;

    try {
      // Apple Reminders format: "Aug  9, 2025 at 15:30"
      // Convert to a format that JavaScript can parse
      const cleaned = dateStr.replace(/\s+/g, " ").trim();
      const match = cleaned.match(
        /^(\w+)\s+(\d+),\s+(\d+)\s+at\s+(\d+):(\d+)$/
      );

      if (!match) {
        this.log(`Warning: Could not parse reminder date: "${dateStr}"`);
        return null;
      }

      const [, month, day, year, hour, minute] = match;

      // Create date string in ISO format
      const monthNames = {
        Jan: "01",
        Feb: "02",
        Mar: "03",
        Apr: "04",
        May: "05",
        Jun: "06",
        Jul: "07",
        Aug: "08",
        Sep: "09",
        Oct: "10",
        Nov: "11",
        Dec: "12",
      };

      const monthNum = monthNames[month];
      if (!monthNum) {
        this.log(`Warning: Unknown month in reminder date: "${month}"`);
        return null;
      }

      const isoDate = `${year}-${monthNum}-${day.padStart(
        2,
        "0"
      )}T${hour.padStart(2, "0")}:${minute.padStart(2, "0")}:00`;
      return new Date(isoDate);
    } catch (error) {
      this.log(`Error parsing reminder date "${dateStr}": ${error.message}`);
      return null;
    }
  }

  // Check if a date falls within the configured week range
  isDateInWeekRange(date) {
    if (!date) return false;

    // Create start and end Date objects for comparison
    const startDate = new Date(`${this.config.sinceDate}T00:01:00`);
    const endDate = new Date(`${this.config.untilDate}T23:59:59`);

    return date >= startDate && date <= endDate;
  }

  // Fetch reminders via MCP
  async fetchReminders() {
    if (!this.config.enableReminders) {
      this.log("Reminders disabled by user");
      return "";
    }

    if (!this.commandExists("mcp") || !this.commandExists("jq")) {
      this.log(
        "Reminders requested but dependencies not available (mcp or jq missing)"
      );
      return "";
    }

    this.log(
      `Fetching reminders from MCP server: ${this.config.remindersServer}`
    );

    try {
      const mcpCommand = `mcp call list_reminders --params "{\\"list\\":\\"${this.config.remindersList}\\",\\"showCompleted\\":true}" ${this.config.remindersServer}`;

      const reminderJson = execSync(mcpCommand, {
        encoding: "utf8",
        stdio: ["pipe", "pipe", "ignore"],
      });

      if (!reminderJson.trim()) {
        this.log("MCP returned empty response");
        return "";
      }

      // Parse and filter reminders by date range (matching bash script logic)
      const data = JSON.parse(reminderJson);
      const reminders = data.reminders || [];

      const filteredReminders = reminders
        .filter((r) => {
          // Must be completed and have a due date
          if (!r.isCompleted || !r.dueDate) {
            return false;
          }

          // Parse the Apple Reminders date format
          const dueDate = this.parseAppleReminderDate(r.dueDate);
          if (!dueDate) {
            return false;
          }

          // Check if the due date falls within our week range
          return this.isDateInWeekRange(dueDate);
        })
        .sort((a, b) => {
          // Sort by due date (matching bash script behavior)
          const dateA = this.parseAppleReminderDate(a.dueDate);
          const dateB = this.parseAppleReminderDate(b.dueDate);
          return dateA - dateB;
        })
        .map((r) => {
          const notes = r.notes
            ? ` — ${r.notes.replace(/[\r\n\t]/g, " ")}`
            : "";
          return `- ${r.title || "Untitled"} — due ${r.dueDate}${notes}`;
        });

      return filteredReminders.join("\n");
    } catch (error) {
      this.log("Failed to fetch reminders: " + error.message);
      return "";
    }
  }

  // Expand GitHub organizations to repositories
  async expandGitHubRepos() {
    if (!this.config.enableGitHub || this.config.repos.length === 0) {
      this.log(
        this.config.enableGitHub
          ? "GitHub enabled but no repositories specified"
          : "GitHub disabled by user"
      );
      return [];
    }

    if (!this.commandExists("gh")) {
      this.log('GitHub requested but "gh" command not available');
      return [];
    }

    this.log("Expanding GitHub organizations and repositories");
    const allRepos = new Set();

    for (const arg of this.config.repos) {
      if (arg.includes("/")) {
        // It's a repo
        allRepos.add(arg);
      } else {
        // It's an org, expand it
        try {
          const repoListCommand = `gh repo list "${arg}" --limit 1000 --json nameWithOwner,isArchived --jq '.[] | select(.isArchived==false) | .nameWithOwner'`;
          const repoList = execSync(repoListCommand, { encoding: "utf8" });
          repoList
            .trim()
            .split("\n")
            .filter((r) => r)
            .forEach((repo) => allRepos.add(repo));
        } catch (error) {
          this.warning(`Failed to expand org "${arg}": ${error.message}`);
        }
      }
    }

    return Array.from(allRepos);
  }

  // Fetch GitHub activity for a repository
  async fetchRepoActivity(repo) {
    const activities = {
      prMerged: [],
      prOpenedOpen: [],
      prClosedNoMerge: [],
      prReviewed: [],
      issueOpenedOpen: [],
      issueClosed: [],
      issueInteracted: [],
    };

    try {
      // PRs merged this week
      const prMergedCmd = `gh pr list -R "${repo}" --state merged --limit 1000 --search "author:@me is:pr is:merged merged:${this.config.dateRange}" --json number,title,url,mergedAt --jq '.[] | [.number, .title, .url, .mergedAt] | @tsv'`;
      const prMerged = execSync(prMergedCmd, {
        encoding: "utf8",
        stdio: ["pipe", "pipe", "ignore"],
      });
      activities.prMerged = this.parseTsvOutput(prMerged, "PR");

      // PRs opened this week and still open
      const prOpenedCmd = `gh pr list -R "${repo}" --state open --limit 1000 --search "author:@me is:pr state:open created:${this.config.dateRange}" --json number,title,url,createdAt --jq '.[] | [.number, .title, .url, .createdAt] | @tsv'`;
      const prOpened = execSync(prOpenedCmd, {
        encoding: "utf8",
        stdio: ["pipe", "pipe", "ignore"],
      });
      activities.prOpenedOpen = this.parseTsvOutput(prOpened, "PR");

      // Issues opened this week and still open
      const issueOpenedCmd = `gh issue list -R "${repo}" --state open --limit 1000 --search "author:@me is:issue state:open created:${this.config.dateRange}" --json number,title,url,createdAt --jq '.[] | [.number, .title, .url, .createdAt] | @tsv'`;
      const issueOpened = execSync(issueOpenedCmd, {
        encoding: "utf8",
        stdio: ["pipe", "pipe", "ignore"],
      });
      activities.issueOpenedOpen = this.parseTsvOutput(issueOpened, "ISSUE");
    } catch (error) {
      this.log(`Failed to fetch activity for ${repo}: ${error.message}`);
    }

    return { repo, activities };
  }

  // Parse TSV output from gh commands
  parseTsvOutput(output, type) {
    if (!output.trim()) return [];

    return output
      .trim()
      .split("\n")
      .map((line) => {
        const [number, title, url, date] = line.split("\t");
        return {
          type,
          number,
          title: title?.replace(/[\t\r\n]/g, " "),
          url,
          date,
        };
      })
      .filter((item) => item.number);
  }

  // Render a section
  renderSection(header, items) {
    if (items.length === 0 && !this.config.showEmpty) {
      return "";
    }

    let section = `- ${header} (${items.length})\n`;

    if (items.length > 0) {
      items.forEach((item) => {
        section += `  • #${item.number} ${item.date} — ${item.title} (${item.url})\n`;
      });
    } else {
      section += "  (none)\n\n";
    }

    return section;
  }

  // Generate GitHub text
  async generateGitHubText() {
    const repos = await this.expandGitHubRepos();

    if (repos.length === 0) {
      return "";
    }

    this.log(`Processing GitHub activity for ${repos.length} repositories`);
    let githubText = "";

    for (const repo of repos) {
      githubText += `#### ${repo}\n`;

      const { activities } = await this.fetchRepoActivity(repo);

      githubText += this.renderSection("PRs — Merged", activities.prMerged);
      githubText += this.renderSection(
        "PRs — Opened & still open",
        activities.prOpenedOpen
      );
      githubText += this.renderSection(
        "Issues — Opened & still open",
        activities.issueOpenedOpen
      );

      githubText += "\n";
    }

    return githubText;
  }

  // Build the main prompt
  buildPrompt(remindersText, githubText) {
    let prompt = `You are my "Shipyard update" formatter. Using my raw weekly notes (Apple Reminders + GitHub activity), produce a Slack-ready Markdown summary grouped by project and focused on delivered value.

Output format (strict):
- Use section titles: **Project A**, **Project B**, **Project C**, **Others**... (use the project name as the section title)
- Everything under each section title must be bullets or sub-bullets (no free-text paragraphs).
- For each project:
  - Start with one value-focused summary bullet.
  - Then a PRs sub-list where each item is the PR **title** as a Markdown link to the PR URL (not \`#123\`). After the link, add a status icon for slack — :merged:, :opened:, :reviewed: etc... any icon that makes sense and can be a github emoji used in slack.
  - If relevant, add an Issues sub-list: link issue titles the same way with a status tag.
- Others: bullets for non-code items (syncs, credentials, Slack threads), linking titles when possible.
- Order: Merged PRs → Opened PRs → Issues.
- Don't list all Reviewed PRs in different bullet points, squash them into a single bullet, with description of the scope (if relevant, like I review 10 PRs of the same scope feat(scope-name) following the conventional PR title format) and add the #123 link of all of them in parenthesis.
- Keep bullets clear, concise, and value-first. Use "-" for bullets; two-space indent for sub-bullets. Skip empty sections.

Week range: ${this.config.sinceDate} → ${this.config.untilDate}

Below are my raw items for this week:
`;

    if (remindersText) {
      prompt += `### Completed tasks (Apple Reminders — list: ${this.config.remindersList})\n${remindersText}\n\n`;
    }

    if (githubText) {
      prompt += `### GitHub activity\n${githubText}`;
    }

    if (!remindersText && !githubText) {
      if (!this.config.enableReminders && !this.config.enableGitHub) {
        prompt +=
          "(All data sources disabled. Use --reminders and/or --github to enable data collection.)\n";
      } else if (
        !this.config.enableReminders &&
        this.config.repos.length === 0
      ) {
        prompt +=
          "(Reminders disabled and no GitHub repositories specified. Provide org/repo arguments or enable reminders.)\n";
      } else {
        prompt += "(No items found in this window.)\n";
      }
    }

    return prompt;
  }

  // Format output
  formatOutput(prompt) {
    switch (this.config.outputFormat) {
      case "slack":
        return prompt
          .replace(/\*\*([^*]+)\*\*/g, "*$1*")
          .replace(/### /g, "\n*")
          .replace(/#### /g, "*")
          .replace(/^- /gm, "• ")
          .replace(/^  - /gm, "    ◦ ");
      case "markdown":
      default:
        return prompt;
    }
  }

  // Send prompt to DeepSeek AI
  async sendToDeepSeek(prompt) {
    const apiKey =
      this.envVars.DEEPSEEK_API_KEY || process.env.DEEPSEEK_API_KEY;

    if (!apiKey) {
      this.error(
        "DEEPSEEK_API_KEY not found. Please add it to .env.shipyard file in the same directory as this script.\nExample: DEEPSEEK_API_KEY=your_api_key_here"
      );
    }

    if (!globalThis.fetch) {
      this.error(
        "Fetch API not available. Please use Node.js 18+ or install node-fetch: npm install node-fetch"
      );
    }

    this.log("Sending prompt to DeepSeek AI...");

    try {
      const response = await fetch(
        "https://api.deepseek.com/v1/chat/completions",
        {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${apiKey}`,
          },
          body: JSON.stringify({
            model: "deepseek-reasoner",
            messages: [
              {
                role: "user",
                content: prompt,
              },
            ],
            temperature: 0.7,
          }),
        }
      );

      if (!response.ok) {
        const errorText = await response.text();
        this.error(`DeepSeek API error (${response.status}): ${errorText}`);
      }

      const data = await response.json();

      if (this.config.verbose) {
        this.log("Complete DeepSeek API response:");
        this.log(JSON.stringify(data, null, 2));
      }

      if (!data.choices || !data.choices[0] || !data.choices[0].message) {
        this.error("Invalid response format from DeepSeek API");
      }

      this.log("AI processing completed successfully");

      // DeepSeek reasoner puts final answer in content, reasoning process in reasoning_content
      const aiResponse =
        data.choices[0].message.content ||
        data.choices[0].message.reasoning_content;

      if (!aiResponse) {
        this.error("AI returned empty response");
      }

      return aiResponse;
    } catch (error) {
      this.error(`Failed to process with DeepSeek AI: ${error.message}`);
    }
  }

  // Copy to clipboard
  copyToClipboard(text) {
    if (!this.config.copyToClipboard) return;

    try {
      if (this.commandExists("pbcopy")) {
        const proc = spawn("pbcopy", [], { stdio: "pipe" });
        proc.stdin.write(text);
        proc.stdin.end();
        console.log(
          `✅ Shipyard prompt (${this.config.outputFormat}) copied to clipboard.`
        );
      } else {
        this.warning(
          "--copy requested, but pbcopy not found. Printing to stdout instead."
        );
      }
    } catch (error) {
      this.warning(`Failed to copy to clipboard: ${error.message}`);
    }
  }

  // Main execution
  async run(args) {
    this.parseArgs(args);
    this.validate();
    this.setupDateRange();

    // Load environment variables after parsing args (so verbose flag is set)
    this.envVars = this.loadEnvFile();
    if (this.config.verbose && Object.keys(this.envVars).length > 0) {
      this.log(
        `Loaded .env.shipyard with ${
          Object.keys(this.envVars).length
        } variables`
      );
    }

    this.log("Configuration:");
    this.log(`  Time range: ${this.config.since} → ${this.config.until}`);
    this.log(`  Reminders enabled: ${this.config.enableReminders}`);
    this.log(`  GitHub enabled: ${this.config.enableGitHub}`);
    this.log(`  Output format: ${this.config.outputFormat}`);
    this.log(
      `  GitHub repos: ${
        this.config.repos.length > 0 ? this.config.repos.join(", ") : "none"
      }`
    );

    const remindersText = await this.fetchReminders();
    const githubText = await this.generateGitHubText();
    const prompt = this.buildPrompt(remindersText, githubText);
    const formattedOutput = this.formatOutput(prompt);

    let finalOutput = formattedOutput;

    // Process with AI if requested
    if (this.config.useAI) {
      finalOutput = await this.sendToDeepSeek(formattedOutput);
    }

    this.copyToClipboard(finalOutput);
    console.log(finalOutput);
  }
}

// Run if called directly
if (require.main === module) {
  const generator = new ShipyardGenerator();
  generator.run(process.argv.slice(2)).catch((error) => {
    console.error("ERROR:", error.message);
    process.exit(1);
  });
}

module.exports = ShipyardGenerator;
