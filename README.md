# 🚀 Mac Maintenance & Optimization Checker

**Is your Mac feeling sluggish?** Over time, every Mac accumulates gigabytes of stale caches, orphaned tools, and forgotten packages that drain performance and eat up disk space.

This lightweight script gives you a **full health check in under 60 seconds** and tells you exactly how to fix it.

It is optimized to surface actionable findings instead of noisy status lines.

---

## 🛡️ Safe by Design
By default, this script is **read-only**. It never deletes, modifies, or uploads your data. It simply surfaces findings so you can make informed decisions.

With the `--prune-docker` flag, the script can perform Docker system cleanup (removing unused images, containers, networks, and build caches) after obtaining your explicit confirmation.

With the `--output` flag, the script also writes the report to a Markdown file in the current directory using the pattern `macmaintain_check_[date-time].md`.

## 🔍 What It Audits

| Category | What it checks |
|:---|:---|
| **Security** | Pending updates, Firewall, SIP, Gatekeeper, and FileVault status. |
| **Storage** | Deep dive into system caches, Xcode data, Docker VMs, npm, and Gradle. |
| **Performance** | System uptime and disk capacity alerts. |
| **Language Runtimes** | Shows installed developer runtimes and SDKs such as Java, Node, Python, Ruby, Go, Rust, .NET, Swift, Kotlin, Scala, Gradle, Maven, Flutter, and more, plus uninstall guidance. |
| **CLI Tools** | **The unique part:** Finds binaries not touched in 1+ year and shows a short description of what each tool is used for. |

Runtime findings are informational only: the script reports versions and installation paths it finds in your `PATH`, then suggests the safest common uninstall route for each runtime or SDK.

### 🧠 Smarter Unused Tool Detection
Unlike basic scripts, this one identifies **how** a tool was installed, shows a short **Used for** description, and gives you the **exact command** to remove it. It supports:
- **Homebrew**
- **NPM**
- **Cargo (Rust)**
- **Ruby Gems**
- **pipx (Python)**
- **macOS Pkg Installers**

Example output for an old CLI binary:

```text
- jq
  Installed via : Homebrew
  Used for      : Processes and transforms JSON data from the command line.
  How to remove : brew uninstall jq
```

---

## 📦 Installation

### Via Homebrew (Recommended)

```bash
# Add the tap
brew tap pdnhan/maintain https://github.com/pdnhan/homebrew-maintain

# Install
brew install macmaintain

# Run
macmaintain

# Run with Docker cleanup
macmaintain --prune-docker

# Save the report as a Markdown file in the current directory
macmaintain --output
```

### Manual Installation

```bash
# Clone
git clone https://github.com/pdnhan/mac-maintenance-script.git
cd mac-maintenance-script

# Run directly
bash mac_maintenance.sh

# Or install to /usr/local/bin (requires sudo)
sudo ln -s "$(pwd)/mac_maintenance.sh" /usr/local/bin/macmaintain
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

## 🔄 Development & Releases

### Creating a New Release / Shipping to Homebrew

1. Update `CHANGELOG.md` with the release notes.
2. Commit the release changes and create a git tag:
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0"
   git push origin v1.0.0
   ```
   Or use the helper script:
   ```bash
   ./release.sh 1.0.0
   ```
3. Create a GitHub release for that tag.
4. Update `Formula/macmaintain.rb` with the new release tarball URL and SHA256:
   ```bash
   curl -sL https://github.com/pdnhan/mac-maintenance-script/archive/refs/tags/v1.0.0.tar.gz | shasum -a 256
   ```
5. Test the formula locally:
   ```bash
   brew install --build-from-source Formula/macmaintain.rb
   ```
6. Push the updated formula to the tap/repository used for Homebrew distribution.

### Testing Locally

```bash
# Test the formula locally
brew install --build-from-source Formula/macmaintain.rb

# Or use fully-qualified path
brew install ./Formula/macmaintain.rb
```

## 🤝 Contributing
Found a new cache location or a better way to detect tools? Pull requests are welcome!

---

*Friendly reminder: Always review suggestions before running destructive commands. This script provides the map; you drive the car.*
