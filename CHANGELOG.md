# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Language runtime audit for common developer runtimes and SDKs including Java, Node, Python, Ruby, Go, Rust, .NET, Swift, Kotlin, Scala, Gradle, Maven, Flutter, and others, with detected versions, install paths, and common uninstall guidance.

### Changed
- README feature overview now documents the runtime audit and its informational-only behavior.

## [1.0.0] - 2025-01-01

### Added
- Initial release as Homebrew-installable CLI tool
- Binary renamed from `mac_maintenance.sh` to `macmaintain`
- Homebrew formula for easy installation
- Man page (`man macmaintain`)
- Security checks: macOS updates, Firewall, SIP, Gatekeeper, FileVault
- Storage analysis: caches, Docker, Ollama models
- Performance metrics: uptime, disk space
- Unused CLI tool detection with removal commands
- `--prune-docker` flag for interactive Docker cleanup
- `--help` flag for usage information
- Color-coded output: `[OK]`, `[SUGGESTION]`, `[WARN]`

### Changed
- Improved error handling for Docker commands
- Enhanced documentation for cloud storage exclusions

### Fixed
- Initial bug fixes and polish
