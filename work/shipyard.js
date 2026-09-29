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
      copyToClipboard: false,
      enableReminders: true,
      enableGitHub: true,
      remindersList: "Work",
      remindersServer: "mcp-server-apple-reminders",
      verbose: false,
      useAI: false,
      targetAuthor: "@me",
      // null = default: my agent app when reporting on myself
      extraAuthors: null,
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
        case "--copy":
          this.config.copyToClipboard = true;
          break;
        case "--no-reminders":
          this.config.enableReminders = false;
          break;
        case "--no-github":
          this.config.enableGitHub = false;
          break;
        case "--verbose":
        case "-v":
          this.config.verbose = true;
          break;
        case "--ai":
          this.config.useAI = true;
          break;
        case "--author":
        case "--target-author":
          this.config.targetAuthor = args[++i] || "@me";
          break;
        case "--extra-author":
          this.config.extraAuthors = [
            ...(this.config.extraAuthors || []),
            args[++i],
          ].filter(Boolean);
          break;
        case "--no-extra-authors":
          this.config.extraAuthors = [];
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

    if (this.config.extraAuthors === null) {
      this.config.extraAuthors =
        this.config.targetAuthor === "@me" ? ["app/rphf-zm-agent"] : [];
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
  --no-reminders                 Disable Apple Reminders
  --no-github                    Disable GitHub activity

Output Options:
  --copy                         Copy output to clipboard (macOS only)
  --verbose, -v                  Show verbose output
  --ai                           Send prompt to DeepSeek AI for processing (requires .env.shipyard)

GitHub Options:
  --author, --target-author USERNAME  GitHub username to fetch activity for (default: @me)
  --extra-author AUTHOR          Also count PRs by AUTHOR as the target's work,
                                 repeatable (default with @me: app/rphf-zm-agent)
  --no-extra-authors             Only count the target author's own PRs

General Options:
  --help, -h                     Show this help message

Examples:
  # Basic usage - current week with both reminders and GitHub
  node shipyard.js my-org owner/repo

  # Only reminders, no GitHub
  node shipyard.js --no-github

  # Only GitHub for specific repos, no reminders
  node shipyard.js --no-reminders my-org owner/repo

  # Custom date range
  node shipyard.js --since 2025-01-01 --until 2025-01-07 my-org

  # Copy to clipboard for immediate use
  node shipyard.js my-org --copy

  # Process with AI and copy AI response
  node shipyard.js my-org --ai --copy

  # Generate report for a specific coworker
  node shipyard.js --author coworker-username my-org

  # Generate report for a coworker with custom date range
  node shipyard.js --author coworker-username --since 2025-01-01 --until 2025-01-07 my-org

  # The report will include:
  # - PRs authored and merged by the coworker
  # - PRs authored by the coworker that are still open
  # - PRs reviewed by the coworker
`);
  }

  // Validate configuration
  validate() {
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

  // Authors whose PRs count as the target's work. My GitHub app opens
  // PRs on my behalf, so include it when reporting on myself.
  authors() {
    return [this.config.targetAuthor, ...this.config.extraAuthors];
  }

  // Resolve "@me" to a login, needed to match review authors
  targetLogin() {
    if (this.config.targetAuthor !== "@me") return this.config.targetAuthor;
    if (!this.cachedLogin) {
      this.cachedLogin = execSync("gh api user --jq .login", {
        encoding: "utf8",
      }).trim();
    }
    return this.cachedLogin;
  }

  // Run `gh <kind> list` and return parsed JSON
  ghList(kind, repo, state, search, fields) {
    const cmd = `gh ${kind} list -R "${repo}" --state ${state} --limit 1000 --search "${search}" --json ${fields}`;
    return JSON.parse(
      execSync(cmd, { encoding: "utf8", stdio: ["pipe", "pipe", "ignore"] })
    );
  }

  // Search once per author (multiple author: qualifiers are ANDed) and merge
  ghListByAuthors(kind, repo, state, search, fields, dateField) {
    const seen = new Map();
    for (const author of this.authors()) {
      for (const item of this.ghList(
        kind,
        repo,
        state,
        `author:${author} ${search}`,
        fields
      )) {
        seen.set(item.number, item);
      }
    }
    return this.toItems([...seen.values()], dateField);
  }

  toItems(list, dateField) {
    return list
      .map((item) => ({
        number: String(item.number),
        title: item.title?.replace(/[\t\r\n]/g, " "),
        url: item.url,
        date: item[dateField],
      }))
      .sort((a, b) => new Date(a.date) - new Date(b.date));
  }

  // PRs by others where the target submitted a review inside the week.
  // `reviewed-by:` + `updated:` alone matches any PR reviewed in the past that
  // got a new commit or rebase this week, and our own PRs (thread replies count
  // as reviews), so filter on the review timestamps. Search updated since the
  // week start: a PR reviewed this week but touched after it is still in scope.
  fetchReviewedPRs(repo) {
    const login = this.targetLogin();
    const ownAuthors = new Set([login, ...this.config.extraAuthors]);
    const prs = this.ghList(
      "pr",
      repo,
      "all",
      `reviewed-by:${login} is:pr updated:>=${this.config.sinceDate}`,
      "number,title,url,author,reviews"
    );

    const reviewed = [];
    for (const pr of prs) {
      if (ownAuthors.has(pr.author?.login)) continue;
      const reviewDates = (pr.reviews || [])
        .filter((r) => r.author?.login === login)
        .map((r) => new Date(r.submittedAt))
        .filter((d) => this.isDateInWeekRange(d));
      if (reviewDates.length === 0) continue;
      const latest = new Date(Math.max(...reviewDates));
      reviewed.push({ ...pr, reviewedAt: latest.toISOString() });
    }
    return this.toItems(reviewed, "reviewedAt");
  }

  // Fetch GitHub activity for a repository
  fetchRepoActivity(repo) {
    const range = this.config.dateRange;
    const activities = { merged: [], opened: [], reviewed: [] };

    try {
      activities.merged = this.ghListByAuthors(
        "pr",
        repo,
        "merged",
        `is:pr is:merged merged:${range}`,
        "number,title,url,mergedAt",
        "mergedAt"
      );
      activities.opened = this.ghListByAuthors(
        "pr",
        repo,
        "open",
        `is:pr state:open created:${range}`,
        "number,title,url,createdAt",
        "createdAt"
      );
      activities.reviewed = this.fetchReviewedPRs(repo);
    } catch (error) {
      this.log(`Failed to fetch activity for ${repo}: ${error.message}`);
    }

    return activities;
  }

  // "ZenMaid/zenmaid-webapp" -> "Webapp"
  repoLabel(repo) {
    const [owner, name] = repo.split("/");
    const short = name.replace(new RegExp(`^${owner}-`, "i"), "");
    return short.charAt(0).toUpperCase() + short.slice(1);
  }

  // Render one repo as a Slack-ready list of PRs
  renderRepo(repo, { merged, opened, reviewed }) {
    const lines = [`${this.repoLabel(repo)}:`];
    const link = (pr) => `[${pr.title.trim()}](${pr.url})`;

    merged.forEach((pr) => lines.push(` - ${link(pr)} :merged:`));
    opened.forEach((pr) => lines.push(` - ${link(pr)} :opened:`));

    if (reviewed.length > 0) {
      const refs = reviewed.map((pr) => `[#${pr.number}](${pr.url})`);
      const count = `${reviewed.length} PR${reviewed.length === 1 ? "" : "s"}`;
      // No parens around the links: Slack swallows the ")" after a link's "(url)"
      lines.push(` - Reviewed ${count}: ${refs.join(", ")} :reviewed:`);
    }

    return lines.join("\n");
  }

  // Generate the PR list for all repos with activity
  async generateGitHubText() {
    const repos = await this.expandGitHubRepos();
    this.log(`Processing GitHub activity for ${repos.length} repositories`);

    const blocks = [];
    const reviewedTitles = [];
    for (const repo of repos) {
      const activities = this.fetchRepoActivity(repo);
      const { merged, opened, reviewed } = activities;
      if (merged.length + opened.length + reviewed.length === 0) continue;
      blocks.push(this.renderRepo(repo, activities));
      reviewed.forEach((pr) =>
        reviewedTitles.push(`- ${this.repoLabel(repo)} #${pr.number}: ${pr.title.trim()}`)
      );
    }

    return { list: blocks.join("\n\n"), reviewedTitles };
  }

  // Build the output: a prompt for the agent, then the PR list
  buildPrompt(remindersText, { list, reviewedTitles }) {
    if (!list && !remindersText) {
      return `(No activity found for ${this.config.sinceDate} → ${this.config.untilDate}.)`;
    }

    let prompt = `Below are my PRs for this week (${this.config.sinceDate} → ${this.config.untilDate}), grouped by repo. Summarize what I did as a short bullet list:
- One short line per bullet, a handful of bullets in total. Group related PRs into one bullet.
- Plain text only: no links, no PR numbers, no emojis, no bold, no sub-bullets.
- Do not repeat or reformat the PR list; I paste it myself.
- Output only the bullet list, nothing else.
`;

    if (remindersText) {
      prompt += `\nAlso include these completed non-code tasks, skipping any already covered by a PR:\n${remindersText}\n`;
    }

    if (reviewedTitles.length > 0) {
      prompt += `\nTitles of the PRs I reviewed:\n${reviewedTitles.join("\n")}\n`;
    }

    if (list) {
      prompt += `\n---\n\n${list}\n`;
    }
    return prompt;
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
        console.log(`✅ Shipyard prompt copied to clipboard.`);
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
    this.log(`  Target author: ${this.config.targetAuthor}`);
    this.log(`  Extra authors: ${this.config.extraAuthors.join(", ") || "none"}`);
    this.log(
      `  GitHub repos: ${
        this.config.repos.length > 0 ? this.config.repos.join(", ") : "none"
      }`
    );

    const remindersText = await this.fetchReminders();
    const githubText = await this.generateGitHubText();
    const prompt = this.buildPrompt(remindersText, githubText);

    let finalOutput = prompt;

    // Process with AI if requested
    if (this.config.useAI) {
      finalOutput = await this.sendToDeepSeek(prompt);
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
