#!/usr/bin/env bash

# Test the Homebrew formula locally

set -e

echo "Testing macmaintain formula..."

# Method 1: Install from local formula file
echo ""
echo "Method 1: Direct formula install"
echo "  brew install --build-from-source Formula/macmaintain.rb"

# Method 2: If you have a local tap
echo ""
echo "Method 2: Install from local tap"
echo "  brew tap pdnhan/maintain"
echo "  brew install macmaintain --build-from-source"

echo ""
echo "Manual test:"
echo "  bash mac_maintenance.sh --help"
echo "  bash mac_maintenance.sh"

# Quick validation
bash mac_maintenance.sh --help