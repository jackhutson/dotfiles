---
phase: 04-app-ecosystem
plan: 01
subsystem: infra
tags: [chezmoi, homebrew, pacman, yay, package-management]

# Dependency graph
requires:
  - phase: 03-core-configs
    provides: chezmoi template patterns, .chezmoidata conventions
provides:
  - Declarative package lists in packages.yaml
  - macOS package installation via Homebrew
  - Arch Linux package installation via pacman/yay
  - run_onchange scripts that trigger on package list changes
affects: [04-02-app-configs, future package additions]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - run_onchange_before_ prefix for pre-apply execution
    - sha256sum hash in comment for change detection
    - brew bundle with heredoc for declarative macOS packages
    - pacman --needed --noconfirm for idempotent Linux packages

key-files:
  created:
    - home/.chezmoidata/packages.yaml
    - home/.chezmoiscripts/run_onchange_before_darwin-install-packages.sh.tmpl
    - home/.chezmoiscripts/run_onchange_before_linux-install-packages.sh.tmpl
  modified: []

key-decisions:
  - "kanata omitted from packages (manual install per prior decision)"
  - "nvm is macOS-only (Homebrew install)"
  - "brew bundle via heredoc stdin (no Brewfile needed)"
  - "yay conditional (graceful degradation if not installed)"

patterns-established:
  - "packages.yaml as single source of truth for all packages"
  - "run_onchange_before_ for package installation before config apply"
  - "sha256sum hash triggers re-run on content change"
  - "Platform-conditional scripts: {{- if eq .chezmoi.os darwin -}}"

# Metrics
duration: 2min
completed: 2026-01-19
---

# Phase 4 Plan 1: Package Management Summary

**Declarative package management via packages.yaml with Homebrew (macOS) and pacman/yay (Arch Linux) scripts**

## Performance

- **Duration:** 2 min
- **Started:** 2026-01-19T03:00:56Z
- **Completed:** 2026-01-19T03:03:00Z
- **Tasks:** 3
- **Files created:** 3

## Accomplishments
- Centralized package lists in packages.yaml (darwin + linux sections)
- macOS script generates Brewfile on-the-fly via brew bundle
- Linux script handles pacman packages with conditional yay for AUR
- Change detection via sha256sum ensures scripts only re-run when packages.yaml changes

## Task Commits

Each task was committed atomically:

1. **Task 1: Create packages.yaml data file** - `538052b` (feat)
2. **Task 2: Create macOS package installation script** - `4c0f03c` (feat)
3. **Task 3: Create Arch Linux package installation script** - `18b5fb6` (feat)

## Files Created/Modified
- `home/.chezmoidata/packages.yaml` - Declarative package lists for both OS
- `home/.chezmoiscripts/run_onchange_before_darwin-install-packages.sh.tmpl` - macOS Homebrew installation
- `home/.chezmoiscripts/run_onchange_before_linux-install-packages.sh.tmpl` - Arch Linux pacman/yay installation

## Decisions Made
- **kanata omitted:** Per prior user decision, kanata is manual install (opt-in reduces complexity)
- **nvm macOS-only:** Homebrew provides nvm cleanly; Linux users can use system package or manual install
- **brew bundle via stdin:** Using heredoc eliminates need for separate Brewfile, keeps everything in one script
- **yay conditional:** If yay not installed, script prints helpful message rather than failing

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

Template verification via `chezmoi execute-template` could not run because the dotfiles repo is not the active chezmoi source directory. Template syntax was verified manually by reviewing the file structure. This is expected behavior during development before the dotfiles are deployed.

## User Setup Required

None - package installation happens automatically on `chezmoi apply`.

## Next Phase Readiness
- Package infrastructure complete and ready for use
- Next plan (04-02) can add app configs (Neovim, Ghostty, etc.)
- Adding new packages is simple: edit packages.yaml, run `chezmoi apply`

---
*Phase: 04-app-ecosystem*
*Completed: 2026-01-19*
