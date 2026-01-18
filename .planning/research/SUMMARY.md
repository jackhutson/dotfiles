# Project Research Summary

**Project:** Cross-Platform Dotfiles with Chezmoi
**Domain:** Multi-OS dotfiles management (2 macOS + 1 Arch Linux + Linux VMs)
**Researched:** 2026-01-18
**Confidence:** HIGH

## Executive Summary

Chezmoi is the clear choice for cross-platform dotfiles management. The 2025 ecosystem is mature and well-documented: Chezmoi v2.69.3 handles templating and orchestration, 1Password CLI provides secrets injection without storing credentials in the repo, and platform-specific package managers (Homebrew/pacman) are triggered via `run_onchange_` scripts. This is a straightforward implementation with well-established patterns.

The recommended approach is to build incrementally: first establish core infrastructure (config prompts, ignore rules), then add 1Password integration, followed by shell/git configs, and finally package management scripts. The architecture should use `.chezmoiroot` to separate managed dotfiles from repository metadata (README, planning docs). Device differentiation is handled through template conditionals (`.chezmoi.os`, `.chezmoi.hostname`) and the `.chezmoiignore` file.

The main risks are operational, not technical: accidentally pushing secrets before 1Password is configured, editing target files directly instead of using `chezmoi edit`, and inverted logic in `.chezmoiignore`. All are preventable with proper initial setup. Configure `add.secrets = "error"` and establish 1Password integration before adding any sensitive files.

## Key Findings

### Recommended Stack

The stack is minimal and stable. Chezmoi is a single binary with no dependencies, actively maintained (latest release 2026-01-16). 1Password CLI integrates natively via `onepasswordRead` template function. No additional encryption tools needed since 1Password handles secrets.

**Core technologies:**
- **Chezmoi v2.69.3:** Dotfiles management, templating, orchestration -- industry standard, native 1Password support
- **1Password CLI (op) v2.32.0:** Secrets injection -- already have 1Password, biometric auth on macOS, secrets never in repo
- **Homebrew + Brewfile:** macOS package management -- declarative, integrates with `run_onchange_` scripts
- **pacman:** Arch package management -- native, use shell script with package list

**Do NOT use:** GNU Stow (no templating), YADM (poorly maintained Jinja dependency), GPG (complexity), Age for 1Password-available secrets (redundant), Nix Home Manager (overkill for this use case).

### Expected Features

**Must have (table stakes):**
- Templates (`.tmpl`) for device/OS differences
- Config file (`chezmoi.toml`) for machine-specific data (email, work flag)
- `.chezmoi.toml.tmpl` for init-time prompts
- `.chezmoiignore` with OS/device conditionals
- 1Password integration for all secrets
- `run_onchange_` scripts for package installation
- `chezmoi diff` workflow before apply

**Should have (differentiators):**
- `.chezmoidata.yaml` for shared static data
- `.chezmoitemplates/` for reusable fragments
- `run_before_`/`run_after_` ordering
- `exact_` directories for plugin folders

**Defer (v2+):**
- `.chezmoiexternal.toml` for external plugins (adds complexity)
- `modify_` scripts (high complexity, rarely needed)
- Symlink mode (cannot use with templates)
- Age encryption (unnecessary with 1Password)

### Architecture Approach

Use `.chezmoiroot` to create a `home/` subdirectory as the source state root. This cleanly separates managed dotfiles from repository metadata (README, scripts/, .planning/). Scripts are centralized in `.chezmoiscripts/` with OS-specific subdirectories. The naming convention follows chezmoi's prefix ordering: `run_onchange_after_install-packages.sh.tmpl`.

**Major components:**
1. **`home/.chezmoi.toml.tmpl`** -- Prompts for email, isWork, isMinimal during init
2. **`home/.chezmoiignore`** -- Platform-specific exclusions using template conditionals
3. **`home/.chezmoiscripts/`** -- Bootstrap and package installation scripts
4. **`home/dot_config/`** -- Application configs (nvim, ghostty, starship)
5. **`home/private_dot_ssh/`** -- SSH config with 1Password key retrieval

**Build order matters:** Homebrew -> 1Password CLI -> Secrets available -> Everything else. Application configs can be parallelized after secrets are working.

### Critical Pitfalls

1. **Secrets leaked to repo** -- Configure `add.secrets = "error"` and set up 1Password BEFORE adding any files. Never use autoPush while learning.

2. **Editing target files directly** -- Changes overwritten on next `chezmoi apply`. Create aliases (`ce='chezmoi edit'`), always run `chezmoi diff` first.

3. **Inverted .chezmoiignore logic** -- Use `{{ if ne .chezmoi.os "darwin" }}` to ignore macOS files on non-macOS (ignore = exclude, not include).

4. **Newline before shebang in scripts** -- Use `{{-` whitespace-trimming syntax, otherwise scripts fail with "exec format error".

5. **run_once_ hash tracking confusion** -- Prefer `run_onchange_` for most cases. `run_once_` tracks by content hash, so reverting changes won't re-run the script.

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Core Infrastructure
**Rationale:** Must establish templating foundation before any device-specific content. `.chezmoi.toml.tmpl` populates data used by all other templates.
**Delivers:** Working chezmoi init flow, device detection, security configuration
**Addresses:** Templates, config file, `add.secrets = "error"`
**Avoids:** Secrets leak pitfall (#1), wrong file editing pitfall (#2)

**Key files:**
- `.chezmoiroot` (contains: `home`)
- `home/.chezmoi.toml.tmpl` (prompts for email, isWork, isMinimal)
- `home/.chezmoiignore` (platform exclusions)
- Editor configuration for `.tmpl` syntax highlighting

### Phase 2: 1Password Integration
**Rationale:** Secrets access must work before adding any sensitive configs (SSH, git signing keys, API tokens). Critical path dependency.
**Delivers:** Working 1Password retrieval in templates
**Uses:** 1Password CLI, `onepasswordRead` template function
**Avoids:** Session token exposure pitfall (#3), multi-account issues (#10)

**Key files:**
- `run_once_before_install-1password-cli.sh.tmpl`
- Test secret retrieval with simple template
- Document vault/item structure

### Phase 3: Shell and Git Configuration
**Rationale:** Git config needed for repository operations; shell config provides the daily driver environment. Both need device-specific templating.
**Delivers:** Working shell and git on all devices
**Implements:** Template conditionals for email, work machine detection

**Key files:**
- `home/dot_gitconfig.tmpl` (work vs personal email)
- `home/dot_zshrc.tmpl` (OS-specific paths, tool aliases)
- `home/private_dot_ssh/config.tmpl` (1Password key references)
- `home/.chezmoitemplates/shell-aliases`

### Phase 4: Package Management
**Rationale:** Package installation scripts depend on config files being in place (Brewfile location, package lists). Idempotent scripts allow safe re-runs.
**Delivers:** One-command package installation per platform
**Uses:** `run_onchange_` scripts with content hashing

**Key files:**
- `home/Brewfile.tmpl` (macOS packages, work vs personal)
- `home/.chezmoiscripts/darwin/run_onchange_after_install-brew-packages.sh.tmpl`
- `home/.chezmoiscripts/linux/run_onchange_after_install-arch-packages.sh.tmpl`
- `home/.chezmoidata.toml` (shared package lists)

### Phase 5: Application Configs
**Rationale:** Application configs can be added incrementally once core infrastructure works. Low risk, high parallelization.
**Delivers:** Full development environment (nvim, ghostty, starship, etc.)

**Key files:**
- `home/dot_config/nvim/`
- `home/dot_config/ghostty/`
- `home/dot_config/starship.toml`
- Device-specific configs (kanata on macOS only)

### Phase 6: Bootstrap and Polish
**Rationale:** Final phase for fresh machine experience. Depends on all other phases working.
**Delivers:** Single-command setup for new machines

**Key files:**
- Bootstrap script documentation
- `run_once_before_` ordering for dependencies
- macOS defaults script (optional)
- README with setup instructions

### Phase Ordering Rationale

- **Phases 1-2 are sequential:** Config prompts must exist before 1Password can be used, 1Password must work before secrets can be injected.
- **Phases 3-4 can overlap:** Git/shell configs and package scripts can be developed in parallel once 1Password works.
- **Phase 5 is highly parallelizable:** Each application config is independent; add as needed.
- **Phase 6 is polish:** Only after everything works on all devices.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 2 (1Password):** May need research on specific vault structure, item naming conventions, biometric vs CLI auth differences between macOS/Linux
- **Phase 4 (Packages):** May need research on Arch package equivalents for macOS packages, AUR helper choice (yay vs paru)

Phases with standard patterns (skip research-phase):
- **Phase 1 (Core):** Well-documented chezmoi patterns, official examples available
- **Phase 3 (Shell/Git):** Standard templating, many public dotfiles repos as reference
- **Phase 5 (App Configs):** Direct file copying with minimal templating

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Verified against official Chezmoi releases and documentation |
| Features | HIGH | Official documentation, community consensus on best practices |
| Architecture | HIGH | Official Chezmoi patterns, verified directory structure conventions |
| Pitfalls | HIGH | Documented in official FAQ, verified in GitHub discussions |

**Overall confidence:** HIGH

The chezmoi ecosystem is mature, well-documented, and stable. All four devices (2 macOS, 1 Arch, Linux VMs) are standard supported platforms. No exotic requirements or edge cases identified.

### Gaps to Address

- **Kanata configuration:** macOS-only tool for keyboard remapping. May need device-specific research during Phase 5 planning for the exact config structure.
- **Work-specific tools:** Need to identify which tools are work-only vs personal during Phase 1 when defining `isWork` conditional scope.
- **Linux VM minimal setup:** Need to define what "minimal" means (which configs to skip) during Phase 1 when implementing `isMinimal` flag.

## Sources

### Primary (HIGH confidence)
- [chezmoi.io](https://www.chezmoi.io/) -- Official documentation (all phases)
- [chezmoi GitHub releases](https://github.com/twpayne/chezmoi/releases) -- Version verification (v2.69.3)
- [1Password CLI docs](https://developer.1password.com/docs/cli/) -- Secrets integration
- [chezmoi comparison table](https://www.chezmoi.io/comparison-table/) -- Stack decisions

### Secondary (MEDIUM confidence)
- [chezmoi GitHub discussions](https://github.com/twpayne/chezmoi/discussions) -- Pitfall discovery, edge cases
- Community dotfiles repositories -- Architecture patterns

---
*Research completed: 2026-01-18*
*Ready for roadmap: yes*
