# 🚀 Mac Maintenance & Optimization Checker

**Is your Mac feeling sluggish?** Over time, every Mac accumulates gigabytes of stale caches, orphaned tools, and forgotten packages that drain performance and eat up disk space.

This lightweight script gives you a **full health check in under 60 seconds**—and tells you exactly how to fix it.

---

## 🛡️ Safe by Design
This script is **read-only**. It never deletes, modifies, or uploads your data. It simply surfaces findings so you can make informed decisions.

## 🔍 What It Audits

| Category | What it checks |
|:---|:---|
| **Security** | Pending updates, Firewall, SIP, Gatekeeper, and FileVault status. |
| **Storage** | Deep dive into system caches, Xcode data, Docker VMs, npm, and Gradle. |
| **Performance** | System uptime and disk capacity alerts. |
| **CLI Tools** | **The unique part:** Finds binaries not touched in 1+ year. |

### 🧠 Smarter Unused Tool Detection
Unlike basic scripts, this one identifies **how** a tool was installed and gives you the **exact command** to remove it. It supports:
- **Homebrew**
- **NPM**
- **Cargo (Rust)**
- **Ruby Gems**
- **pipx (Python)**
- **macOS Pkg Installers**

---

## 🛠️ Quick Start

Get your first report in seconds:

```bash
# 1. Clone the toolkit
git clone git@github.com:pdnhan/mac-maintenance-script.git
cd mac-maintenance-script

# 2. Run the checker
bash mac_maintenance.sh
```

### 🎨 Color-Coded Results
- `[OK]` — You're good to go!
- `[SUGGESTION]` — Actionable step with a ready-to-use command.

---

## 🤖 The Pro Workflow: Use an AI Agent

The script surfaces the data; an AI agent like **[Claude Code](https://claude.ai/code)** provides the context. 

### Why run this with Claude Code?
1. **Zero False Positives:** The agent knows `git` is vital, even if the `atime` is stale.
2. **One-Click Cleanup:** Just say "Based on the report, clean up everything," and the agent executes the commands for you.
3. **Audit Trail:** Automatically generates a clean Markdown report for your records.

#### Example Prompt:
> "Run @mac_maintenance.sh and give me a prioritized cleanup plan."

---

## 📝 Requirements
- **macOS** (Ventura or later recommended)
- **Zero dependencies** (uses only native tools)

## 🤝 Contributing
Found a new cache location or a better way to detect tools? Pull requests are welcome!

---

*Friendly reminder: Always review suggestions before running destructive commands. This script provides the map; you drive the car.*
