# Requirements Archive: v1 MVP

**Archived:** 2026-01-19
**Status:** ✅ SHIPPED

This is the archived requirements specification for v1.
For current requirements, see `.planning/PROJECT.md` (requirements are defined per-milestone via `/gsd:new-milestone`).

---

# Requirements: Dotfiles

**Defined:** 2025-01-18
**Core Value:** Fresh machine -> productive dev environment in minutes, not hours.

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Core Infrastructure

- [x] **INFRA-01**: `.chezmoi.toml.tmpl` prompts for hostname, email, and device type on init
- [x] **INFRA-02**: `.chezmoiignore` conditionally ignores files based on OS and device type
- [x] **INFRA-03**: `.chezmoiroot` separates source state from repository metadata
- [x] **INFRA-04**: `.chezmoidata.toml` contains static shared configuration data

### Secrets Management

- [x] **SECR-01**: 1Password CLI integrated via `onepasswordRead` template function
- [x] **SECR-02**: No secrets committed to repository (enforced via `.gitignore` and review)
- [x] **SECR-03**: SSH keys managed through 1Password SSH agent
- [x] **SECR-04**: Git commit signing via 1Password

### Shell Configuration

- [x] **SHELL-01**: zsh config (`.zshrc`, `.zprofile`) managed by chezmoi
- [x] **SHELL-02**: oh-my-zsh installed with configured plugins
- [x] **SHELL-03**: starship prompt configured and working
- [x] **SHELL-04**: Shell aliases and functions included (zoxide, etc.)
- [x] **SHELL-05**: `it` tool wrapper included only on work device

### Git Configuration

- [x] **GIT-01**: `.gitconfig` managed with templated user.email
- [x] **GIT-02**: Work email on work device, personal email elsewhere
- [x] **GIT-03**: 1Password SSH signing configured
- [x] **GIT-04**: Standard git settings (rerere, prune, etc.) preserved

### Application Configs

- [x] **APP-01**: nvim config (LazyVim + customizations) managed
- [x] **APP-02**: ghostty config managed
- [x] **APP-03**: htop config managed
- [x] **APP-04**: starship.toml managed
- [x] **APP-05**: gh CLI config managed
- [x] **APP-06**: kanata config stored (macOS only, not auto-installed)

### CLI Tools

- [x] **CLI-01**: bat, eza, fd, fzf, jq, lazygit, ripgrep, zoxide configs included
- [x] **CLI-02**: Tool configs templated where OS-specific differences exist

### Package Management

- [x] **PKG-01**: Brewfile defines macOS packages (formulae and casks)
- [x] **PKG-02**: `run_onchange_` script installs Brewfile on macOS
- [x] **PKG-03**: Arch/CachyOS package script with pacman/yay
- [x] **PKG-04**: `run_onchange_` script installs Arch packages on Linux

### Bootstrap

- [x] **BOOT-01**: Single command bootstrap (`curl | sh` or similar)
- [x] **BOOT-02**: Bootstrap detects OS (macOS vs Linux)
- [x] **BOOT-03**: Bootstrap installs chezmoi if not present
- [x] **BOOT-04**: Bootstrap runs `chezmoi init --apply`

## v2 Requirements (Deferred)

Deferred to future release. Tracked but not in v1 roadmap.

### Enhanced Bootstrap

- **BOOT-05**: Full vs minimal setup flag for VMs
- **BOOT-06**: Post-install verification script
- **BOOT-07**: Rollback capability

### Additional Tooling

- **TOOL-01**: macOS defaults script (dock, finder, etc.)
- **TOOL-02**: Karabiner config (if needed alongside kanata)

### Documentation

- **DOC-01**: README with setup instructions
- **DOC-02**: Per-device documentation

## Out of Scope

Explicitly excluded. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Nix/Home Manager | Deferred, may revisit later for declarative packages |
| Zed config | Just testing, not primary editor |
| Helix config | Just testing, not primary editor |
| Full VM setup | VMs are ephemeral, minimal setup sufficient |
| Windows support | Not using Windows |
| GUI app configs (beyond casks) | Too device-specific, hard to template |
| Automatic kanata installation | Manual install preferred, reduces complexity |

## Traceability

Which phases cover which requirements.

| Requirement | Phase | Status |
|-------------|-------|--------|
| INFRA-01 | Phase 1 | Complete |
| INFRA-02 | Phase 1 | Complete |
| INFRA-03 | Phase 1 | Complete |
| INFRA-04 | Phase 1 | Complete |
| SECR-01 | Phase 2 | Complete |
| SECR-02 | Phase 2 | Complete |
| SECR-03 | Phase 2 | Complete |
| SECR-04 | Phase 2 | Complete |
| SHELL-01 | Phase 3 | Complete |
| SHELL-02 | Phase 3 | Complete |
| SHELL-03 | Phase 3 | Complete |
| SHELL-04 | Phase 3 | Complete |
| SHELL-05 | Phase 3 | Complete |
| GIT-01 | Phase 3 | Complete |
| GIT-02 | Phase 3 | Complete |
| GIT-03 | Phase 3 | Complete |
| GIT-04 | Phase 3 | Complete |
| APP-01 | Phase 4 | Complete |
| APP-02 | Phase 4 | Complete |
| APP-03 | Phase 4 | Complete |
| APP-04 | Phase 4 | Complete |
| APP-05 | Phase 4 | Complete |
| APP-06 | Phase 4 | Complete |
| CLI-01 | Phase 4 | Complete |
| CLI-02 | Phase 4 | Complete |
| PKG-01 | Phase 4 | Complete |
| PKG-02 | Phase 4 | Complete |
| PKG-03 | Phase 4 | Complete |
| PKG-04 | Phase 4 | Complete |
| BOOT-01 | Phase 5 | Complete |
| BOOT-02 | Phase 5 | Complete |
| BOOT-03 | Phase 5 | Complete |
| BOOT-04 | Phase 5 | Complete |

**Coverage:**
- v1 requirements: 32 total
- Shipped: 32
- Coverage: 100%

---

## Milestone Summary

**Shipped:** 32 of 32 v1 requirements
**Adjusted:** None — all requirements shipped as specified
**Dropped:** None

---
*Archived: 2026-01-19 as part of v1 milestone completion*
