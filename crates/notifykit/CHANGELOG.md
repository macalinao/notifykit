# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.2](https://github.com/macalinao/notifykit/compare/v0.1.1...v0.1.2) - 2026-01-19

### Added

- add thread grouping for notifications
- add alert-style notifications with --banner flag

### Fixed

- move resources back to workspace root
- use workspace-relative paths for bundle resources
- move resources into crate directory for cargo-bundle
- correct resource paths for app bundle icon
- allow dead_code for unused InterruptionLevel variants

## [0.1.1](https://github.com/macalinao/notifykit/compare/v0.1.0...v0.1.1) - 2026-01-11

### Fixed

- Use ImageMagick for icon generation and fix workflow YAML

### Other

- Allow --sound flag without argument to use default sound
- Improve cchook notifications with message, cwd, and notification type
- release v0.1.0

## [0.1.0](https://github.com/macalinao/notifykit/releases/tag/v0.1.0) - 2026-01-11

### Other

- Switch to cargo-bundle for app bundling
- Add --sound flag to cchook and sounds command
- code review fixes and simplifications
- wip
