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

- [ ] **SECR-01**: 1Password CLI integrated via `onepasswordRead` template function
- [ ] **SECR-02**: No secrets committed to repository (enforced via `.gitignore` and review)
- [ ] **SECR-03**: SSH keys managed through 1Password SSH agent
- [ ] **SECR-04**: Git commit signing via 1Password

### Shell Configuration

- [ ] **SHELL-01**: zsh config (`.zshrc`, `.zprofile`) managed by chezmoi
- [ ] **SHELL-02**: oh-my-zsh installed with configured plugins
- [ ] **SHELL-03**: starship prompt configured and working
- [ ] **SHELL-04**: Shell aliases and functions included (zoxide, etc.)
- [ ] **SHELL-05**: `it` tool wrapper included only on work device

### Git Configuration

- [ ] **GIT-01**: `.gitconfig` managed with templated user.email
- [ ] **GIT-02**: Work email on work device, personal email elsewhere
- [ ] **GIT-03**: 1Password SSH signing configured
- [ ] **GIT-04**: Standard git settings (rerere, prune, etc.) preserved

### Application Configs

- [ ] **APP-01**: nvim config (LazyVim + customizations) managed
- [ ] **APP-02**: ghostty config managed
- [ ] **APP-03**: htop config managed
- [ ] **APP-04**: starship.toml managed
- [ ] **APP-05**: gh CLI config managed
- [ ] **APP-06**: kanata config stored (macOS only, not auto-installed)

### CLI Tools

- [ ] **CLI-01**: bat, eza, fd, fzf, jq, lazygit, ripgrep, zoxide configs included
- [ ] **CLI-02**: Tool configs templated where OS-specific differences exist

### Package Management

- [ ] **PKG-01**: Brewfile defines macOS packages (formulae and casks)
- [ ] **PKG-02**: `run_onchange_` script installs Brewfile on macOS
- [ ] **PKG-03**: Arch/CachyOS package script with pacman/yay
- [ ] **PKG-04**: `run_onchange_` script installs Arch packages on Linux

### Bootstrap

- [ ] **BOOT-01**: Single command bootstrap (`curl | sh` or similar)
- [ ] **BOOT-02**: Bootstrap detects OS (macOS vs Linux)
- [ ] **BOOT-03**: Bootstrap installs chezmoi if not present
- [ ] **BOOT-04**: Bootstrap runs `chezmoi init --apply`

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

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

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| INFRA-01 | Phase 1 | Complete |
| INFRA-02 | Phase 1 | Complete |
| INFRA-03 | Phase 1 | Complete |
| INFRA-04 | Phase 1 | Complete |
| SECR-01 | Phase 2 | Pending |
| SECR-02 | Phase 2 | Pending |
| SECR-03 | Phase 2 | Pending |
| SECR-04 | Phase 2 | Pending |
| SHELL-01 | Phase 3 | Pending |
| SHELL-02 | Phase 3 | Pending |
| SHELL-03 | Phase 3 | Pending |
| SHELL-04 | Phase 3 | Pending |
| SHELL-05 | Phase 3 | Pending |
| GIT-01 | Phase 3 | Pending |
| GIT-02 | Phase 3 | Pending |
| GIT-03 | Phase 3 | Pending |
| GIT-04 | Phase 3 | Pending |
| APP-01 | Phase 4 | Pending |
| APP-02 | Phase 4 | Pending |
| APP-03 | Phase 4 | Pending |
| APP-04 | Phase 4 | Pending |
| APP-05 | Phase 4 | Pending |
| APP-06 | Phase 4 | Pending |
| CLI-01 | Phase 4 | Pending |
| CLI-02 | Phase 4 | Pending |
| PKG-01 | Phase 4 | Pending |
| PKG-02 | Phase 4 | Pending |
| PKG-03 | Phase 4 | Pending |
| PKG-04 | Phase 4 | Pending |
| BOOT-01 | Phase 5 | Pending |
| BOOT-02 | Phase 5 | Pending |
| BOOT-03 | Phase 5 | Pending |
| BOOT-04 | Phase 5 | Pending |

**Coverage:**
- v1 requirements: 32 total
- Mapped to phases: 32
- Unmapped: 0

---
*Requirements defined: 2025-01-18*
*Last updated: 2026-01-18 after roadmap creation*
