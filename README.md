# Mac Maintenance & Optimization Checker

A lightweight, read-only Bash script that checks your Mac's health across four areas: security, cache bloat, performance, and unused CLI tools. It reports findings and suggestions — it never deletes or modifies anything on its own.

## What it checks

| Area | Details |
|------|---------|
| Security | macOS updates, Firewall, SIP, Gatekeeper, FileVault |
| Cache & Storage | User caches, Xcode, Docker, npm, Gradle, Cargo |
| Performance | System uptime, disk usage |
| Unused CLI Tools | Binaries in common `bin` directories not accessed in 1+ year |

## Usage

```bash
# Clone the repo
git clone git@github.com:pdnhan/mac-maintenance-script.git
cd mac-maintenance-script

# Make executable (first time only)
chmod +x mac_maintenance.sh

# Run
./mac_maintenance.sh
```

Output is color-coded:
- `[OK]` — no action needed
- `[SUGGESTION]` — optional improvement with a recommended command

The script is safe to run at any time. It does **not** delete files, modify settings, or send data anywhere.

## Requirements

- macOS (tested on macOS Ventura and later)
- No external dependencies — uses only built-in macOS tools

---

## Running with an AI agent (recommended)

For a more powerful workflow, let an AI coding agent like **[Claude Code](https://claude.ai/code)** run the script, interpret the results, and take action for you.

### Example with Claude Code

Open your project in Claude Code and prompt it with:

```
Run @mac_maintenance.sh and create a report for me
```

Claude Code will execute the script, parse the output, and generate a structured Markdown report with a prioritized action list.

You can then follow up with:

```
Based on the report, run all the recommended cleanup actions (skip system update)
```

The agent will handle cache clearing, Docker pruning, Homebrew cleanup, and more — asking for confirmation on destructive steps before proceeding.

### Why use an agent?

- The script surfaces raw findings; an agent interprets them in context (e.g., it won't flag `git` or `docker` as "unused" just because `atime` is stale)
- The agent can execute the suggested commands, verify results, and summarize what was freed
- Generates a timestamped report you can keep for reference
