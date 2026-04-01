#!/usr/bin/env bash

# Release script for macmaintain
# Usage: ./release.sh <version>

set -e

VERSION=${1:-}
if [ -z "$VERSION" ]; then
    echo "Usage: ./release.sh <version>"
    echo "Example: ./release.sh 1.0.1"
    exit 1
fi

# Remove 'v' prefix if present
VERSION=${VERSION#v}

echo "=== Releasing macmaintain v${VERSION} ==="

# Update CHANGELOG
if command -v sed &> /dev/null; then
    TODAY=$(date +%Y-%m-%d)
    # Note: Manual update may be needed for CHANGELOG.md
    echo "⚠️  Please update CHANGELOG.md with v${VERSION} changes"
fi

# Commit changes
git add -A
git commit -m "chore: prepare release v${VERSION}"
git push origin master

# Create tag
git tag -a "v${VERSION}" -m "Release v${VERSION}"
git push origin "v${VERSION}"

# Download tarball and calculate SHA256
echo ""
echo "Calculating SHA256 for v${VERSION}..."
sleep 2  # Give GitHub a moment to process

URL="https://github.com/pdnhan/mac-maintenance-script/archive/refs/tags/v${VERSION}.tar.gz"
SHA=$(curl -sL "$URL" | shasum -a 256 | cut -d' ' -f1)

echo ""
echo "✅ Tag created: v${VERSION}"
echo ""
echo "📝 Update Formula/macmaintain.rb:"
echo "   url \"$URL\""
echo "   sha256 \"$SHA\""
echo ""
echo "Then run:"
echo "   git add Formula/macmaintain.rb"
echo "   git commit -m 'chore: update formula for v${VERSION}'"
echo "   git push"