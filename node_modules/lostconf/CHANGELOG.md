# Changelog

All notable changes to lostconf will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0] - 2026-01-27

### Added
- Support for 5 new ignore file parsers (Issue #5):
  - **remark** (`.remarkignore`) - Markdown processor ignore file
  - **lychee** (`.lycheeignore`) - Link checker ignore file
  - **secretlint** (`.secretlintignore`) - Secret detection ignore file
  - **VS Code** (`.vscodeignore`) - VS Code extension ignore file
  - **git-leaks** (`.ignoresecrets`) - Gitleaks alternative ignore file
- Total supported configuration files increased from 62+ to 67+

### Fixed
- `--skip-ignore-files` now properly skips `.stylelintignore` files (Issue #5)
- `--skip-ignore-files` now dynamically skips all ignore file parsers (names ending with 'ignore')
- Future-proof: new ignore file parsers are automatically skipped when using `--skip-ignore-files`

## [0.3.0] - 2026-01-26

### Added
- Support for 10 new popular linters and configuration tools:
  - **ESLint Flat Config** (`eslint.config.json`) - New ESLint v9+ flat configuration format (JSON only)
  - **Oxlint** (`.oxlintrc.json`) - Fast Rust-based JavaScript/TypeScript linter
  - **commitlint** (`.commitlintrc`, `.commitlintrc.json`) - Commit message linting
  - **lint-staged** (`.lintstagedrc`, `.lintstagedrc.json`) - Run linters on staged files
  - **lefthook** (`lefthook.yml`, `.lefthook.yml`) - Fast Go-based git hooks manager
  - **pre-commit** (`.pre-commit-config.yaml`) - Python-based git hooks framework
  - **ansible-lint** (`.ansible-lint`, `.ansible-lint.yaml`) - Ansible playbook linter
  - **SQLFluff** (`.sqlfluff`, `setup.cfg`) - SQL linter supporting 24+ dialects
  - **buf** (`buf.yaml`, `buf.work.yaml`) - Protocol Buffers linter and generator
  - **alex** (`.alexignore`, `.alexrc`, `.alexrc.json`) - Inclusive language linter
- Support for 4 essential Ruby/Rails linters:
  - **Brakeman** (`config/brakeman.yml`, `.brakeman.yml`) - Security vulnerability scanner for Rails
  - **Reek** (`.reek.yml`, `.reek`, `config.reek`) - Code smell detector for Ruby
  - **bundler-audit** (`.bundler-audit.yml`) - Dependency vulnerability scanner
  - **YARD-Lint** (`.yard-lint.yml`) - Documentation linter for YARD docs
- Total supported configuration files increased from 48+ to 62+
- Comprehensive test coverage with 140+ new tests for all new parsers

### Changed
- Updated README with new linter documentation and usage examples

### Fixed
- Alex parser no longer attempts to validate linguistic terms as file paths
- SQLFluff parser now correctly identifies path-related fields (excludes rule IDs and file extensions)
- Commitlint parser logic improved to properly filter npm packages vs. local file paths
- Unused parameter warnings fixed in buf and sqlfluff parsers

## [0.2.1] - 2026-01-26

### Fixed
- Minor documentation updates

## [0.2.0] - 2026-01-26

### Added
- Smart severity classification system (LOW, MEDIUM, HIGH)
- Progress indicator for scanning large repositories
- `--min-severity` option to filter findings by severity level
- `--show-all` flag to show all findings including low severity
- `--skip-ignore-files` option to skip common ignore files
- `--exclude-parsers` option to exclude specific parsers
- `--no-progress` option to disable progress indicator
- Comprehensive validation report across 10 major OSS projects
- Automated NPM publishing workflow with provenance attestation
- Release automation script for streamlined version bumping
- NPM publishing guide with setup instructions
- CHANGELOG.md following Keep a Changelog format
- `.npmignore` to control published package contents

### Changed
- Default behavior now hides LOW severity patterns (use `--show-all` to see them)
- Improved path resolution for relative patterns in nested configs
- Enhanced output formatting with severity indicators

### Fixed
- Path resolution bug causing false positives in nested configuration files
- 52% reduction in false positives for projects like Vite

## [0.1.0] - 2026-01-26

### Added
- Initial release of lostconf meta-linter
- Support for 48+ configuration file types across 15+ languages
- File path, glob pattern, and regex pattern validation
- Multiple output formats: text, JSON, SARIF
- CI/CD integration support
- GitHub Code Scanning integration via SARIF
- Built-in parsers for:
  - JavaScript/TypeScript: ESLint, Prettier, TypeScript, Jest, Stylelint, Biome, Deno
  - Python: pytest, mypy, ruff, black, isort, flake8, pylint, bandit, pyright
  - Ruby: RuboCop
  - Go: golangci-lint
  - Rust: rustfmt, clippy
  - Java: Checkstyle, PMD, SpotBugs
  - Kotlin: detekt
  - PHP: PHP_CodeSniffer, PHPStan
  - Swift: SwiftLint
  - C/C++: clang-tidy, clang-format
  - Scala: Scalafmt, Scalafix
  - Elixir: Credo
  - .NET: EditorConfig, MSBuild
  - Shell: ShellCheck
  - YAML: yamllint
  - Terraform: TFLint
  - Security: Semgrep, Gitleaks
  - Docker: Hadolint
  - General: Git (.gitignore), Docker (.dockerignore), markdownlint
- Command-line options:
  - `--format` (text, json, sarif)
  - `--output` (write to file)
  - `--include` / `--exclude` (filter config files)
  - `--fail-on-stale` (exit code 1 for CI)
  - `--quiet` / `--verbose` (output control)
- Comprehensive test suite with 168+ tests
- Full TypeScript type definitions
- MIT License

### Documentation
- README with detailed usage instructions
- API documentation for programmatic usage
- Examples for CI/CD integration
- Contributing guidelines

[Unreleased]: https://github.com/mensfeld/lostconf/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/mensfeld/lostconf/compare/v0.3.0...v0.4.0
[0.3.0]: https://github.com/mensfeld/lostconf/compare/v0.2.1...v0.3.0
[0.2.1]: https://github.com/mensfeld/lostconf/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/mensfeld/lostconf/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/mensfeld/lostconf/releases/tag/v0.1.0
