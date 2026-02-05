# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-02-05

### Added
- Initial release
- Support for merged cells (cell merge) in table headers
- Support for grouped headers with nested children
- Support for row span (vertical cell merging) in data rows
- Customizable cell styles, colors, and borders
- Responsive column sizing with flex weights

## [1.0.0] - 2026-02-05

### Added
- `rowHeights` support: specify per-row heights via `GroupedTable` / `fromSimpleData`.
- `GroupedTableDataCell.height` override: specify a cell-specific height that takes precedence over row heights.
- Example updated: `example/lib/main.dart` demonstrates `rowHeights` usage.

### Changed
- Bumped package SDK constraint: Flutter SDK >= 3.13.0.
- Public API: package version bumped to `1.0.0` and release tag `v1.0.0` added.

### Fixed
- Removed unnecessary container wrapper in header row to address `avoid_unnecessary_containers` lint.

### Notes
- Row-spanned cells compute height as the sum of the effective heights of spanned rows plus `rowSpacing` between rows.

## [1.0.1] - 2026-02-05

### Fixed
- Fixed README image rendering on pub.dev by embedding example image into the repository
  and referencing it via a relative path (`assets/images/example.png`).

### Changed
- Updated README installation instructions to reference the latest stable version (`^1.0.0`).
- Improved README clarity around merged-cell behavior to better set expectations for UI-level merging.
