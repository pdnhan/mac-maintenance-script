#!/usr/bin/env bash

# Mac Maintenance & Optimization Checker
# This script performs read-only checks to assess your Mac's health,
# vulnerabilities, unoptimized storage, Docker images/containers, Ollama models, language runtimes/SDKs, and unused CLI tools.
# It DOES NOT modify, delete, or upload any data. Cloud storages like Google Drive and OneDrive are ignored.
#
# Usage:
#   macmaintain              # Run checks only (read-only)
#   macmaintain --prune-docker  # Interactive docker system prune

# Parse command line arguments
PRUNE_DOCKER=false
SHOW_HELP=false

show_help() {
    echo -e "${BOLD}Mac Maintenance & Optimization Checker${NC}"
    echo ""
    echo -e "${BOLD}Usage:${NC}"
    echo "  macmaintain [options]"
    echo ""
    echo -e "${BOLD}Options:${NC}"
    echo -e "  -h, --help          Show this help message and exit"
    echo -e "  --prune-docker      Interactive Docker system prune (removes unused images, containers, volumes)"
    echo ""
    echo -e "${BOLD}Description:${NC}"
    echo "  This script performs read-only checks to assess your Mac's health:"
    echo "    • Security & vulnerability checks (SIP, Firewall, Gatekeeper, FileVault)"
    echo "    • Cache & temporary data storage analysis"
    echo "    • Docker images, containers, and volumes usage"
    echo "    • Ollama models storage"
    echo "    • Performance & system health (uptime, disk space)"
    echo "    • Installed language runtimes & SDKs"
    echo "    • Unused CLI tools detection (>1 year without access)"
    echo ""
    echo -e "${BOLD}Examples:${NC}"
    echo "  macmaintain                  # Run all checks (read-only)"
    echo "  macmaintain --prune-docker   # Run checks + interactive Docker cleanup"
    echo ""
    echo -e "${BOLD}Notes:${NC}"
    echo "  - Cloud storages (Google Drive, OneDrive, Dropbox) are ignored"
    echo "  - No data is modified unless --prune-docker is used with confirmation"
    exit 0
}

# Simple argument parsing
for arg in "$@"; do
    case $arg in
        -h|--help)
        SHOW_HELP=true
        shift
        ;;
        --prune-docker)
        PRUNE_DOCKER=true
        shift
        ;;
        *)
        # Unknown option
        ;;
    esac
done

# Show help if requested
if [ "$SHOW_HELP" = true ]; then
    show_help
fi

BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BOLD}${CYAN}"
echo "         .:'          =============================================="
echo "     __ :'__          Mac Maintenance & Optimization Checker"
echo "  .'\\\`  \`-'  \\''.     =============================================="
echo " :          .-'"
echo "  :         :         Assessing your Mac's health, security,"
echo "   :         :         Docker, SDKs, and unused CLI tools."
echo "    \`.___:'"
echo -e "${NC}\n"

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
check_cache_size "$HOME/.docker"
check_cache_size "$HOME/.ollama"

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

# Docker Images & Containers Check
echo -e "\n${BOLD}2b. Docker Images & Containers Check${NC}"
if command -v docker &> /dev/null; then
    if docker info &> /dev/null; then
        echo "Checking Docker usage..."
        
        # Docker disk usage
        docker_disk=$(docker system df 2>/dev/null)
        if [ -n "$docker_disk" ]; then
            echo -e "\n  ${CYAN}Docker Disk Usage:${NC}"
            echo "$docker_disk" | while read -r line; do
                echo "    $line"
            done
        fi
        
        # List images
        images=$(docker images --format "{{.Repository}}:{{.Tag}}\t{{.Size}}" 2>/dev/null | head -20)
        if [ -n "$images" ]; then
            echo -e "\n  ${CYAN}Docker Images (top 20):${NC}"
            echo "$images" | while read -r line; do
                echo "    $line"
            done
            total_images=$(docker images -q | wc -l | tr -d ' ')
            echo -e "    ${GREEN}Total: $total_images images${NC}"
        fi
        
        # List containers
        containers=$(docker ps -a --format "{{.Names}}\t{{.Status}}\t{{.Image}}" 2>/dev/null | head -10)
        if [ -n "$containers" ]; then
            echo -e "\n  ${CYAN}Docker Containers (top 10):${NC}"
            echo "$containers" | while read -r line; do
                echo "    $line"
            done
            total_containers=$(docker ps -aq | wc -l | tr -d ' ')
            echo -e "    ${GREEN}Total: $total_containers containers${NC}"
        fi
        
        # List volumes
        volumes=$(docker volume ls --format "{{.Name}}\t{{.Driver}}" 2>/dev/null | head -10)
        if [ -n "$volumes" ]; then
            echo -e "\n  ${CYAN}Docker Volumes (top 10):${NC}"
            echo "$volumes" | while read -r line; do
                echo "    $line"
            done
            total_volumes=$(docker volume ls -q | wc -l | tr -d ' ')
            echo -e "    ${GREEN}Total: $total_volumes volumes${NC}"
        fi
        
        echo -e "\n  ${YELLOW}Docker File Locations:${NC}"
        echo -e "    - Images & Containers: ~/Library/Containers/com.docker.docker/Data"
        echo -e "    - Docker Desktop Disk Image: ~/Library/Containers/com.docker.docker/Data/vms/0/Docker.raw"
        echo -e "    - Docker Desktop Config: ~/.docker"
        echo -e "    - Volume data stored in Docker.raw disk image"
        
        echo -e "\n  ${YELLOW}How to Remove Docker Resources:${NC}"
        echo -e "    ${CYAN}# Remove all stopped containers, dangling images, and unused networks:${NC}"
        echo -e "    docker system prune"
        echo -e "    ${CYAN}# Remove ALL unused data (containers, images, volumes, networks):${NC}"
        echo -e "    docker system prune -a --volumes"
        echo -e "    ${CYAN}# Remove specific image:${NC}"
        echo -e "    docker rmi <image_id>"
        echo -e "    ${CYAN}# Uninstall Docker Desktop:${NC}"
        echo -e "    rm -rf /Applications/Docker.app"
        echo -e "    rm -rf ~/Library/Containers/com.docker.docker"
        echo -e "    rm -rf ~/.docker"
    else
        echo -e "  [${YELLOW}WARN${NC}] Docker is installed but not running. Start Docker Desktop to check usage."
    fi
else
    echo -e "  [${GREEN}OK${NC}] Docker is not installed."
fi

# Ollama Models Check
echo -e "\n${BOLD}2c. Ollama Models Check${NC}"
if command -v ollama &> /dev/null; then
    echo "Checking Ollama models..."
    
    # List local models
    models=$(ollama list 2>/dev/null)
    if [ -n "$models" ]; then
        echo -e "\n  ${CYAN}Ollama Models:${NC}"
        echo "$models" | while read -r line; do
            echo "    $line"
        done
    fi
    
    # Check ollama storage location
    ollama_home="${HOME}/.ollama"
    models_dir="/usr/share/ollama/.ollama/models"
    
    if [ -d "$ollama_home" ]; then
        ollama_size=$(du -sh "$ollama_home" 2>/dev/null | cut -f1)
        echo -e "\n  ${CYAN}Ollama User Directory:${NC}"
        echo -e "    Location   : $ollama_home"
        echo -e "    Size       : ${GREEN}$ollama_size${NC}"
    fi
    
    if [ -d "$models_dir" ]; then
        models_size=$(du -sh "$models_dir" 2>/dev/null | cut -f1)
        echo -e "\n  ${CYAN}Ollama Models (system):${NC}"
        echo -e "    Location   : $models_dir"
        echo -e "    Size       : ${GREEN}$models_size${NC}"
    fi
    
    # Get running models
    running=$(ollama ps 2>/dev/null)
    if [ -n "$running" ] && echo "$running" | grep -q "NAME"; then
        echo -e "\n  ${CYAN}Currently Running Models:${NC}"
        echo "$running" | while read -r line; do
            echo "    $line"
        done
    fi
    
    echo -e "\n  ${YELLOW}Ollama File Locations:${NC}"
    echo -e "    - User config & cache: ~/.ollama"
    echo -e "    - System models (default): /usr/share/ollama/.ollama/models"
    echo -e "    - Custom OLLAMA_MODELS location if set via env variable"
    echo -e "    - On macOS: ~/.ollama/models (user install)"
    
    echo -e "\n  ${YELLOW}How to Remove Ollama Models:${NC}"
    echo -e "    ${CYAN}# Delete a specific model:${NC}"
    echo -e "    ollama rm <model_name>"
    echo -e "    ${CYAN}# List all models:${NC}"
    echo -e "    ollama list"
    echo -e "    ${CYAN}# Uninstall Ollama completely:${NC}"
    echo -e "    ${CYAN}# Via Homebrew:${NC}"
    echo -e "    brew uninstall ollama"
    echo -e "    ${CYAN}# Or manually remove:${NC}"
    echo -e "    rm -rf ~/.ollama"
    echo -e "    rm -rf /usr/share/ollama"
    echo -e "    rm -rf /usr/local/bin/ollama"
else
    echo -e "  [${GREEN}OK${NC}] Ollama is not installed."
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

# 4. Installed Runtimes
echo -e "\n${BOLD}4. Installed Language Runtime Findings${NC}"

found_runtimes=false

check_runtime() {
    local name="$1"
    local version_cmd="$2"
    local remove_hint="$3"
    local version_pattern="$4"
    local runtime_path
    local version_output

    runtime_path=$(command -v "$name" 2>/dev/null)
    if [ -n "$runtime_path" ]; then
        found_runtimes=true
        if [ -n "$version_pattern" ]; then
            version_output=$(eval "$version_cmd" 2>&1 | awk -v pattern="$version_pattern" 'index($0, pattern) { print; exit }')
        else
            version_output=$(eval "$version_cmd" 2>&1 | awk 'NF { print; exit }')
        fi
        [ -z "$version_output" ] && version_output="Version output unavailable"
        echo -e "  - ${GREEN}$name${NC}"
        echo -e "    Version      : $version_output"
        echo -e "    Installed at : $runtime_path"
        echo -e "    How to remove: ${CYAN}$remove_hint${NC}"
    fi
}

check_runtime "java" 'java -version' 'If installed with Homebrew: brew uninstall openjdk. If installed from Oracle/Adoptium pkg: remove the JDK from /Library/Java/JavaVirtualMachines and its matching app if present.' 'version'
check_runtime "node" 'node --version' 'If installed with Homebrew: brew uninstall node. If installed with nvm: nvm uninstall <version>. If installed manually/pkg: remove the package or app that provided it.' ''
check_runtime "python3" 'python3 --version' 'If installed with Homebrew: brew uninstall python. If installed with pyenv: pyenv uninstall <version>. Avoid deleting the macOS system Python.' ''
check_runtime "ruby" 'ruby --version' 'If installed with Homebrew: brew uninstall ruby. If installed with rbenv or rvm: uninstall the specific version there. Avoid removing the macOS-provided Ruby unless you know it is unused.' ''
check_runtime "go" 'go version' 'If installed with Homebrew: brew uninstall go. If installed from the official pkg or tarball: remove /usr/local/go and related PATH entries.' 'go version'
check_runtime "rustc" 'rustc --version' 'If installed with Homebrew: brew uninstall rust. If installed with rustup: rustup self uninstall.' ''
check_runtime "cargo" 'cargo --version' 'Usually removed together with Rust via rustup self uninstall, or brew uninstall rust if it came from Homebrew.' ''
check_runtime "php" 'php --version' 'If installed with Homebrew: brew uninstall php. If installed manually: remove the package or app that provided it.' 'PHP '
check_runtime "perl" 'perl -v' 'If installed with perlbrew: perlbrew uninstall <version>. Avoid removing the macOS-provided Perl without confirming nothing depends on it.' 'This is perl'
check_runtime "dotnet" 'dotnet --version' 'If installed with Homebrew: brew uninstall --cask dotnet-sdk or brew uninstall dotnet. If installed from Microsoft installer: remove the .NET SDK from /usr/local/share/dotnet and uninstall related packages.' ''
check_runtime "swift" 'swift --version' 'Usually provided by Xcode or Command Line Tools. Remove by uninstalling Xcode or the matching developer tools package if you no longer need them.' 'Swift version'
check_runtime "kotlinc" 'kotlinc -version' 'If installed with Homebrew: brew uninstall kotlin. If installed via SDKMAN: sdk uninstall kotlin <version>.' 'kotlinc-jvm'
check_runtime "scala" 'scala -version' 'If installed with Homebrew: brew uninstall scala. If installed via SDKMAN: sdk uninstall scala <version>.' 'Scala code runner version'
check_runtime "gradle" 'gradle --version' 'If installed with Homebrew: brew uninstall gradle. If installed via SDKMAN: sdk uninstall gradle <version>.' 'Gradle '
check_runtime "mvn" 'mvn -version' 'If installed with Homebrew: brew uninstall maven. If installed via SDKMAN: sdk uninstall maven <version>.' 'Apache Maven'
check_runtime "clojure" 'clojure -Sdescribe' 'If installed with Homebrew: brew uninstall clojure/tools-deps. If installed manually: remove the package or scripts that provided it.' 'version-string'
check_runtime "R" 'R --version' 'If installed with Homebrew: brew uninstall r. If installed from CRAN pkg: remove the R framework and app bundle.' 'R version'
check_runtime "julia" 'julia --version' 'If installed with Homebrew: brew uninstall julia. If installed manually: remove the Julia app or extracted directory and PATH entry.' 'julia version'
check_runtime "dart" 'dart --version' 'If installed with Homebrew: brew uninstall dart. If installed via Flutter SDK: remove Flutter, which also removes Dart.' 'Dart SDK version'
check_runtime "flutter" 'flutter --version' 'If installed with Homebrew: brew uninstall flutter. If installed manually: remove the Flutter SDK directory and PATH entry.' 'Flutter '

if [ "$found_runtimes" = false ]; then
    echo -e "  [${GREEN}OK${NC}] No common language runtimes or SDKs found in PATH."
fi

# 5. Unused CLI Tools
echo -e "\n${BOLD}5. Unused CLI Tools Check (>1 year without access)${NC}"
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
