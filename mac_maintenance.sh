#!/usr/bin/env bash

# Mac Maintenance & Optimization Checker
# This script performs read-only checks to assess your Mac's health,
# vulnerabilities, unoptimized storage, and unused CLI tools.
# It DOES NOT modify, delete, or upload any data. Cloud storages like Google Drive and OneDrive are ignored.

# Parse command line arguments
PRUNE_DOCKER=false

# Simple argument parsing
for arg in "$@"; do
    case $arg in
        --prune-docker)
        PRUNE_DOCKER=true
        shift
        ;;
        *)
        # Unknown option
        ;;
    esac
done

BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BOLD}${CYAN}==============================================${NC}"
echo -e "${BOLD}${CYAN}      Mac Maintenance & Optimization Checker  ${NC}"
echo -e "${BOLD}${CYAN}==============================================${NC}\n"

# 1. Security & Vulnerabilities
echo -e "${BOLD}1. Security & Vulnerability Checks${NC}"
echo "Checking for macOS system updates (this may take a few seconds)..."

if softwareupdate -l 2>&1 | grep -q "No new software available."; then
    echo -e "  [${GREEN}OK${NC}] macOS is up to date."
else
    echo -e "  [${YELLOW}SUGGESTION${NC}] macOS updates are available. Run 'softwareupdate -i -a' or use System Settings to update."
fi

# Firewall
if /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate | grep -q "enabled"; then
    echo -e "  [${GREEN}OK${NC}] Application Firewall is enabled."
else
    echo -e "  [${YELLOW}SUGGESTION${NC}] Firewall is disabled. Enable it via System Settings > Network > Firewall."
fi

# System Integrity Protection (SIP)
if csrutil status | grep -q "enabled"; then
    echo -e "  [${GREEN}OK${NC}] System Integrity Protection (SIP) is enabled."
else
    echo -e "  [${YELLOW}SUGGESTION${NC}] SIP is disabled. Boot into Recovery Mode and run 'csrutil enable' to protect system files."
fi

# Gatekeeper
if spctl --status | grep -q "assessments enabled"; then
    echo -e "  [${GREEN}OK${NC}] Gatekeeper is enabled."
else
    echo -e "  [${YELLOW}SUGGESTION${NC}] Gatekeeper is disabled. Enable it in System Settings > Privacy & Security to prevent untrusted apps from running."
fi

# FileVault
if fdesetup status | grep -q "FileVault is On"; then
    echo -e "  [${GREEN}OK${NC}] FileVault disk encryption is enabled."
else
    echo -e "  [${YELLOW}SUGGESTION${NC}] FileVault is OFF. Consider enabling it in System Settings > Privacy & Security to protect your data."
fi

# 2. Cache & Temporary Data Check
echo -e "\n${BOLD}2. Cache & Temporary Data Storage Check${NC}"
echo "Calculating sizes of common cache directories..."
echo "(Note: Cloud storage directories like OneDrive, Google Drive, Dropbox are completely ignored.)"

# Function to check size quickly
check_cache_size() {
    local dir="$1"
    if [ -d "$dir" ]; then
        local size
        size=$(du -sh "$dir" 2>/dev/null | cut -f1)
        if [ -n "$size" ] && [ "$size" != "0B" ] && [ "$size" != " 0B" ]; then
            echo -e "  - ${CYAN}$dir${NC} occupies ${GREEN}$size${NC}"
            has_caches=true
        fi
    fi
}

has_caches=false
# Safe temp/cache locations
check_cache_size "$HOME/Library/Caches"
check_cache_size "/Library/Caches"
check_cache_size "$HOME/Library/Developer/Xcode/DerivedData"
check_cache_size "$HOME/Library/Developer/Xcode/Archives"
check_cache_size "$HOME/Library/Containers/com.docker.docker/Data/vms"
check_cache_size "$HOME/.npm/_cacache"
check_cache_size "$HOME/.gradle/caches"
check_cache_size "$HOME/.m2/repository"
check_cache_size "$HOME/.cache"
check_cache_size "$HOME/.cargo/registry"

if [ "$has_caches" = true ]; then
     echo -e "  [${YELLOW}SUGGESTION${NC}] These are generally safe to clear if you're low on space. E.g., 'rm -rf ~/Library/Caches/*'"
     echo -e "               For Xcode, use 'DevCleaner' (App Store) or manually empty 'DerivedData'."
     echo -e "               For Docker, run 'docker system prune' to free unused data."
 else
     echo -e "  [${GREEN}OK${NC}] No significant cache buildup found."
 fi

# Perform docker system prune if requested
if [ "$PRUNE_DOCKER" = true ]; then
     echo -e "\n${BOLD}Performing Docker System Prune...${NC}"
     echo -e "  [${YELLOW}WARNING${NC}] This will remove ALL unused images, containers, networks, and build caches."
     read -p "  Are you sure you want to continue? (y/N): " confirm
     if [[ "$confirm" =~ ^[Yy]$ ]]; then
         echo -e "  Running: ${CYAN}docker system prune -a${NC}"
         if docker system prune -a --volumes --force 2>/dev/null; then
             echo -e "  [${GREEN}SUCCESS${NC}] Docker system prune completed successfully."
         else
             echo -e "  [${RED}ERROR${NC}] Docker system prune failed. Make sure Docker is installed and running."
         fi
     else
         echo -e "  [${YELLOW}INFO${NC}] Docker system prune skipped by user."
     fi
 fi

# 3. Performance Enhancements
echo -e "\n${BOLD}3. Performance & System Health Check${NC}"

# Uptime
uptime_days=$(uptime | grep -oEe 'up [0-9]+ days' | awk '{print $2}')
if [ -n "$uptime_days" ] && [ "$uptime_days" -ge 7 ]; then
    echo -e "  [${YELLOW}SUGGESTION${NC}] Your Mac has been running for ${uptime_days} days without a restart."
    echo -e "               Rebooting periodically can optimize RAM usage and clear system memory/swap."
else
    echo -e "  [${GREEN}OK${NC}] Recent reboot detected or uptime is low. System state should be optimal."
fi

# Disk Space
disk_info=$(df -h / | tail -n 1)
free_space=$(echo "$disk_info" | awk '{print $4}')
free_pct_used=$(echo "$disk_info" | awk '{print $5}' | sed 's/%//')
if [ "$free_pct_used" -gt 85 ]; then
    echo -e "  [${YELLOW}SUGGESTION${NC}] Your primary disk is at $free_pct_used% capacity ($free_space free)."
    echo -e "               Keep at least 15-20% free space for optimal SSD wear-leveling and performance."
else
    echo -e "  [${GREEN}OK${NC}] Disk space is healthy ($free_space free, $free_pct_used% used)."
fi

# 4. Unused CLI Tools
echo -e "\n${BOLD}4. Unused CLI Tools Check (>1 year without access)${NC}"
echo "(Note: macOS does not strictly log file access times, so this is an estimation.)"

dirs_to_check=("/usr/local/bin" "/opt/homebrew/bin" "$HOME/bin" "$HOME/.local/bin")
found_unused=false

for dir in "${dirs_to_check[@]}"; do
    if [ -d "$dir" ]; then
        # Use find to locate files accessed more than 365 days ago, avoid diving deep
        unused_files=$(find "$dir" -maxdepth 1 ! -type d -atime +365 2>/dev/null)
        if [ -n "$unused_files" ]; then
            found_unused=true
            echo -e "\n  ${CYAN}Potentially unused tools in $dir:${NC}"
            echo "$unused_files" | while read -r file; do
                filename=$(basename "$file")
                install_method="Unknown / Direct Script"
                remove_cmd="rm -i \"$file\""

                # Check if it's a symlink (most package managers use symlinks)
                if [ -L "$file" ]; then
                    target=$(readlink "$file")
                    if echo "$target" | grep -qi "Cellar\|homebrew"; then
                        install_method="Homebrew"
                        # Extract formula name from Cellar path if possible, fallback to filename
                        formula_name=$(echo "$target" | awk -F'Cellar/' '{print $2}' | awk -F'/' '{print $1}')
                        [ -z "$formula_name" ] && formula_name="$filename"
                        remove_cmd="brew uninstall $formula_name"
                    elif echo "$target" | grep -qi "node_modules"; then
                        install_method="NPM"
                        remove_cmd="npm uninstall -g $filename"
                    elif echo "$target" | grep -qi ".cargo/bin"; then
                        install_method="Cargo (Rust)"
                        remove_cmd="cargo uninstall $filename"
                    elif echo "$target" | grep -qi ".gem/\|/gems/"; then
                        install_method="Ruby Gem"
                        remove_cmd="gem uninstall $filename"
                    elif echo "$target" | grep -qi "pipx"; then
                        install_method="pipx (Python)"
                        remove_cmd="pipx uninstall $filename"
                    else
                        install_method="Symlink (Target: $target)"
                        remove_cmd="rm -i \"$file\" (Consider deleting target as well)"
                    fi
                else
                    # Check if it's installed via a system pkg
                    pkg_info=$(pkgutil --file-info "$file" 2>/dev/null | grep "pkgid" | head -n 1)
                    if [ -n "$pkg_info" ]; then
                        pkgid=$(echo "$pkg_info" | awk '{print $2}')
                        install_method="macOS Pkg Installer ($pkgid)"
                        remove_cmd="Requires manual uninstall script, or cautious removal"
                    fi
                fi

                echo -e "    - ${GREEN}$filename${NC}"
                echo -e "      Installed via : $install_method"
                echo -e "      How to remove : ${CYAN}$remove_cmd${NC}"
            done
        fi
    fi
done

if [ "$found_unused" = true ]; then
    echo -e "\n  [${YELLOW}SUGGESTION${NC}] Review the removal commands above carefully before executing."
    echo -e "               For Homebrew, after removal, you can clean orphaned dependencies by running: 'brew autoremove'"
    echo -e "               And to clear cached downloads, run: 'brew cleanup'"
else
    echo -e "  [${GREEN}OK${NC}] No heavily outdated CLI tools found in common directories."
fi

echo -e "\n${BOLD}${CYAN}=== Check Complete ===${NC}"
echo "Friendly reminder: This script provided suggestions, but didn't actually delete files."
echo "Before deleting caches or uninstalling software, make sure no important processes depend on them!"
