# lostconf

[![CI](https://github.com/mensfeld/lostconf/actions/workflows/ci.yml/badge.svg)](https://github.com/mensfeld/lostconf/actions/workflows/ci.yml)
[![npm version](https://img.shields.io/npm/v/lostconf.svg)](https://www.npmjs.com/package/lostconf)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A meta-linter that validates and detects stale references in configuration files across languages and tools.

## The Problem

Linter configs accumulate exclusions over time. Files get deleted, patterns become stale, but configs are never cleaned up. This leads to:

- **Confusing config files** full of dead references that nobody understands
- **Security risks** when exclusions outlive the code they were meant to exclude
- **Maintenance burden** when trying to understand what's actually being ignored
- **False confidence** in your linting when patterns no longer match anything

## The Solution

lostconf scans your config files, extracts path/glob/regex patterns, validates them against your codebase, and reports dead references.

```
$ npx lostconf
.eslintignore:3    src/legacy/*.js       no matches
.rubocop.yml:47    spec/old_helper.rb    file not found
pyproject.toml:12  test_.*_old\.py       no matches

Found 3 stale patterns in 3 files
```

## Installation

Run directly with npx (no install required):

```bash
npx lostconf
```

Or install globally:

```bash
npm install -g lostconf
```

Or add to your project:

```bash
npm install --save-dev lostconf
```

## Quick Start

```bash
# Scan current directory (shows medium+ severity by default)
npx lostconf

# Show all findings including low severity (common patterns like node_modules)
npx lostconf --show-all

# Only show high severity issues
npx lostconf --min-severity=high

# Scan specific paths
npx lostconf ./src ./lib

# Fail CI if stale patterns found
npx lostconf --fail-on-stale

# JSON output for automation
npx lostconf --format json

# Only check TypeScript configs
npx lostconf --include "**/tsconfig.json"
```

## CLI Options

### Filtering Options

- `--skip-ignore-files` - Skip all ignore files (.gitignore, .prettierignore, .eslintignore, .dockerignore, .stylelintignore, etc.). Reduces noise by 70-80% since these files contain many intentionally missing patterns.
- `--exclude-parsers <names...>` - Skip specific parsers by name (e.g., `--exclude-parsers gitignore prettierignore`)
- `--include <glob...>` - Only check config files matching these glob patterns (e.g., `--include "**/tsconfig.json"`)
- `--exclude <glob...>` - Skip config files matching these glob patterns (e.g., `--exclude "**/test/**"`)

### Output Options

- `-f, --format <fmt>` - Output format: `text` (default), `json`, or `sarif`
- `-o, --output <file>` - Write results to file instead of stdout
- `--fail-on-stale` - Exit with code 1 if stale patterns are found (useful for CI)
- `-q, --quiet` - Suppress non-error output
- `-v, --verbose` - Show detailed debug information

### Progress

- `--no-progress` - Disable the progress indicator (enabled by default in text mode)

### Examples

```bash
# Focus on actionable issues (skip ignore files)
npx lostconf --skip-ignore-files

# Check only TypeScript configs in packages directory
npx lostconf packages/ --include "**/tsconfig.json"

# CI mode: fail build if stale patterns found, output JSON
npx lostconf --fail-on-stale --format json --skip-ignore-files

# Scan large monorepo with progress disabled
npx lostconf --no-progress

# Check everything except test directories
npx lostconf --exclude "**/test/**" --exclude "**/tests/**"
```

## Supported Config Files

lostconf supports **67+ configuration files** from popular tools across **15+ languages**:

| Language/Category | Tool | Config File(s) | What We Check |
|-------------------|------|----------------|---------------|
| **JavaScript/TypeScript** | ESLint | `.eslintignore` | File paths and glob patterns in ignore list |
| | ESLint Flat Config | `eslint.config.json` | Patterns in `ignores` and `files` arrays (JSON only) |
| | Prettier | `.prettierignore` | File paths and glob patterns in ignore list |
| | TypeScript | `tsconfig.json` | Files in `exclude`, `include` arrays |
| | Jest | `jest.config.json` | Test paths, coverage paths, module paths |
| | Stylelint | `.stylelintignore`, `.stylelintrc.json` | File paths and glob patterns, ignore patterns in config |
| | Biome | `biome.json`, `biome.jsonc` | Patterns in `files.ignore`, `linter.ignore`, `formatter.ignore` |
| | Deno | `deno.json`, `deno.jsonc` | Global `exclude`, `lint.exclude/include`, `fmt.exclude/include`, `test.exclude/include` |
| | Oxlint | `.oxlintrc.json`, `oxlint.config.json` | Patterns in `ignorePatterns` array |
| | commitlint | `.commitlintrc`, `.commitlintrc.json` | Commit message patterns in `ignores`, file paths in `extends` |
| | lint-staged | `.lintstagedrc`, `.lintstagedrc.json` | Object keys are glob patterns matching staged files |
| **Python** | pytest, coverage, mypy, ruff, black, isort | `pyproject.toml` | Test paths, source paths, exclude patterns, omit patterns |
| | Flake8 | `.flake8`, `setup.cfg` | Exclude patterns, extend-exclude, filename patterns, per-file-ignores |
| | Pylint | `.pylintrc`, `pylintrc` | Ignore paths, ignore patterns in `[MASTER]`/`[MAIN]` section |
| | Bandit | `.bandit` | Exclude directories, exclude files, test paths |
| | Pyright | `pyrightconfig.json` | `include`, `exclude`, `ignore`, `extraPaths` patterns |
| **SQL** | SQLFluff | `.sqlfluff`, `setup.cfg` | Exclude patterns, ignore patterns, template paths |
| **Ruby** | RuboCop | `.rubocop.yml` | Exclude patterns, Include patterns in AllCops |
| | Brakeman | `config/brakeman.yml`, `.brakeman.yml` | Patterns in `skip-files` and `only-files` |
| | Reek | `.reek.yml`, `.reek`, `config.reek` | Directory paths in `exclude_paths` |
| | bundler-audit | `.bundler-audit.yml` | Advisory IDs in `ignore` (CVE, OSVDB, GHSA) |
| | YARD-Lint | `.yard-lint.yml` | File patterns in global and per-validator `Exclude` |
| **Go** | golangci-lint | `.golangci.yml` | Skip-dirs, skip-files, exclude patterns |
| **Rust** | rustfmt | `rustfmt.toml` | Ignore patterns |
| | Clippy | `clippy.toml` | Excluded files |
| **Java** | Checkstyle | `checkstyle.xml` | SuppressionFilter file attributes |
| | PMD | `pmd.xml` | Exclude patterns in rulesets |
| | SpotBugs | `spotbugs.xml` | Match/Class elements |
| **Kotlin** | detekt | `detekt.yml` | Excludes patterns in config |
| **PHP** | PHP_CodeSniffer | `phpcs.xml` | Exclude-pattern elements |
| | PHPStan | `phpstan.neon` | Excludes_analyse, ignoreErrors paths |
| **Swift** | SwiftLint | `.swiftlint.yml` | Excluded paths, included paths |
| **C/C++** | clang-tidy | `.clang-tidy` | CheckOptions paths |
| | clang-format | `.clang-format` | File patterns |
| **Scala** | Scalafmt | `.scalafmt.conf` | Project.excludeFilters |
| | Scalafix | `.scalafix.conf` | Excludes patterns |
| **Elixir** | Credo | `.credo.exs` | Files.excluded paths |
| **.NET** | EditorConfig | `.editorconfig` | File globs and patterns |
| | MSBuild | `Directory.Build.props` | Include/Exclude item patterns |
| **Shell** | ShellCheck | `.shellcheckrc` | Source-path directives |
| **YAML** | yamllint | `.yamllint`, `.yamllint.yml` | Ignore patterns, ignore-from-file paths |
| **Terraform** | TFLint | `.tflint.hcl` | Source paths, module directories, exclude patterns |
| **Security** | Semgrep | `.semgrep.yml`, `.semgrep.yaml`, `.semgrepignore` | `paths.exclude`, `paths.include` in rules, ignore patterns |
| | Gitleaks | `.gitleaks.toml` | `allowlist.paths`, `allowlist.regexes`, rule-specific allowlists |
| **Docker** | Hadolint | `.hadolint.yaml`, `.hadolint.yml` | `ignored` patterns, `trustedRegistries` (non-URL paths) |
| **DevOps** | ansible-lint | `.ansible-lint`, `.ansible-lint.yaml` | Patterns in `exclude_paths` list |
| **Protocol Buffers** | buf | `buf.yaml`, `buf.work.yaml` | Patterns in `lint.ignore`, `breaking.ignore`, workspace `directories` |
| **Git Hooks** | lefthook | `lefthook.yml`, `.lefthook.yml` | Patterns in `files`, `glob`, `exclude`, `skip` fields |
| | pre-commit | `.pre-commit-config.yaml` | Regex patterns in top-level and hook-level `files` and `exclude` |
| **General** | Git | `.gitignore` | All file paths and patterns |
| | Docker | `.dockerignore` | All file paths and patterns |
| | markdownlint | `.markdownlintignore` | All file paths and patterns |
| | remark | `.remarkignore` | All file paths and patterns |
| | lychee | `.lycheeignore` | All file paths and patterns |
| | secretlint | `.secretlintignore` | All file paths and patterns |
| | VS Code | `.vscodeignore` | All file paths and patterns |
| | git-leaks | `.ignoresecrets` | All file paths and patterns |
| **Documentation** | alex | `.alexignore`, `.alexrc`, `.alexrc.json` | Ignore patterns and allowed terms |

## What Does lostconf Validate?

lostconf extracts and validates three types of patterns from configuration files:

### Pattern Types

- **File Paths**: Direct references to files or directories (e.g., `src/legacy/old.js`)
- **Glob Patterns**: Wildcards and patterns (e.g., `**/*.test.js`, `*.py`)
- **Regex Patterns**: Regular expressions in certain config contexts (e.g., Python test file patterns)

### Validation Strategy by Tool

**Ignore Files** (`.gitignore`, `.eslintignore`, `.prettierignore`, etc.)
- Validates that each pattern matches at least one file in your codebase
- Warns about patterns that no longer match anything (stale patterns)

**Configuration Files with Path References** (`tsconfig.json`, `pyproject.toml`, etc.)
- Checks `exclude`, `include`, `ignore`, and similar fields
- Validates source paths, test paths, and coverage paths
- Ensures referenced files and directories exist

**Linter-Specific Configs**
- **ESLint/Prettier/Stylelint**: Ignore patterns
- **TypeScript**: Files in `exclude`/`include` arrays
- **Jest**: Test paths, coverage directories, module path mappings
- **Biome**: Ignore/include patterns across files, linter, and formatter sections
- **Python Tools** (pytest, mypy, ruff, black, isort, flake8, pylint, bandit): Source paths, test paths, exclude patterns
- **RuboCop**: Exclude/Include patterns in AllCops
- **Go** (golangci-lint): Skip directories and files
- **Rust** (rustfmt, clippy): Ignored file patterns
- **Java** (checkstyle, pmd, spotbugs): Suppression files and exclude patterns
- **Kotlin** (detekt): Exclude patterns
- **PHP** (phpcs, phpstan): Exclude patterns and ignored paths
- **Swift** (swiftlint): Excluded and included file paths
- **C/C++** (clang-tidy, clang-format): File patterns and paths
- **Scala** (scalafmt, scalafix): Exclude filters
- **Elixir** (credo): Excluded file paths
- **.NET** (editorconfig, MSBuild): File globs and item patterns
- **ShellCheck**: Source path references
- **yamllint**: Ignore patterns and ignore-from-file references
- **Terraform** (tflint): Module sources and exclude patterns

### What Causes a Stale Pattern?

1. **File Not Found** - A specific file or directory path doesn't exist
2. **No Matches** - A glob or regex pattern doesn't match any files in the codebase
3. **Invalid Pattern** - The pattern syntax is malformed

## CLI Reference

```
lostconf [options] [paths...]

Arguments:
  paths                Paths to scan (default: current directory)

Options:
  -V, --version        Show version number
  -f, --format <fmt>   Output format: text, json, sarif (default: text)
  -o, --output <file>  Write to file instead of stdout
  --include <glob...>  Only check matching config files
  --exclude <glob...>  Skip matching config files
  --fail-on-stale      Exit code 1 if stale patterns found
  -q, --quiet          Suppress non-error output
  -v, --verbose        Show debug info
  -h, --help           Show help
```

## Output Formats

### Text (Default)

Human-readable output with colors:

```
.eslintignore:3    src/legacy/*.js       no matches
.rubocop.yml:47    spec/old_helper.rb    file not found

Found 2 stale patterns in 2 files
```

### JSON

Machine-readable format for automation:

```bash
npx lostconf --format json
```

```json
{
  "findings": [
    {
      "file": ".eslintignore",
      "line": 3,
      "pattern": "src/legacy/*.js",
      "type": "glob",
      "reason": "no_matches",
      "parser": "eslintignore"
    }
  ],
  "summary": { "total": 1, "files": 1 }
}
```

### SARIF

[SARIF](https://sarifweb.azurewebsites.net/) format for IDE integration and GitHub Code Scanning:

```bash
npx lostconf --format sarif --output results.sarif
```

## CI Integration

### GitHub Actions

Basic usage:

```yaml
name: Lint
on: [push, pull_request]

jobs:
  lostconf:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
      - run: npx lostconf --fail-on-stale
```

### GitHub Code Scanning with SARIF

```yaml
name: Code Scanning
on: [push, pull_request]

jobs:
  lostconf:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Run lostconf
        run: npx lostconf --format sarif --output results.sarif
        continue-on-error: true

      - name: Upload SARIF
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: results.sarif
```

### Pre-commit Hook

Add to `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: local
    hooks:
      - id: lostconf
        name: Check for stale config patterns
        entry: npx lostconf --fail-on-stale
        language: system
        pass_filenames: false
```

## Exit Codes

| Code | Description |
|------|-------------|
| 0 | Success (no stale patterns, or `--fail-on-stale` not set) |
| 1 | Stale patterns found (when `--fail-on-stale` is set) |
| 2 | Error (invalid arguments, file read errors, etc.) |

## Programmatic API

Use lostconf as a library in your Node.js scripts:

```typescript
import { createEngine, getBuiltinParsers } from 'lostconf';

async function checkConfigs() {
  const parsers = getBuiltinParsers();
  const engine = createEngine(parsers, {
    paths: ['.'],
    verbose: false
  });

  const result = await engine.run();

  console.log(`Found ${result.summary.total} stale patterns`);

  for (const finding of result.findings) {
    console.log(`${finding.file}:${finding.line} - ${finding.pattern}`);
  }
}

checkConfigs();
```

### Creating Custom Parsers

```typescript
import { createEngine, Parser, Pattern, PatternType } from 'lostconf';

const myParser: Parser = {
  name: 'my-tool',
  filePatterns: ['.mytoolrc', '**/.mytoolrc'],
  parse(filename: string, content: string): Pattern[] {
    const patterns: Pattern[] = [];
    // Parse your config format and extract patterns
    // ...
    return patterns;
  }
};

const engine = createEngine([myParser], { paths: ['.'] });
const result = await engine.run();
```

## Pattern Types

lostconf understands three types of patterns:

| Type | Description | Example |
|------|-------------|---------|
| `path` | Exact file or directory path | `src/legacy/old.js` |
| `glob` | Glob pattern with wildcards | `src/**/*.test.js` |
| `regex` | Regular expression | `test_.*_old\.py` |

## Stale Reasons

| Reason | Description |
|--------|-------------|
| `file_not_found` | The referenced file or directory doesn't exist |
| `no_matches` | The glob/regex pattern doesn't match any files |
| `invalid_pattern` | The pattern syntax is invalid |

## Contributing

Contributions are welcome! Here's how to get started:

```bash
# Clone the repository
git clone https://github.com/mensfeld/lostconf.git
cd lostconf

# Install dependencies
npm install

# Build
npm run build

# Run tests
npm test

# Run linter
npm run lint

# Check formatting
npm run format:check

# Run lostconf on itself
npm run selfcheck
```

### Adding a New Parser

1. Create a new file in `src/parsers/`
2. Implement the `Parser` interface
3. Export the parser from `src/parsers/index.ts`
4. Add tests in `tests/parsers/`

## License

MIT
