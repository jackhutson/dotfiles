# Roadmap: Dotfiles

## Overview

This roadmap transforms a collection of existing configs into a Chezmoi-managed dotfiles repository that bootstraps 4 devices (2 macOS, 1 CachyOS, Linux VMs) to a productive dev environment in minutes. The journey starts with core infrastructure and 1Password integration (the critical path), then adds shell/git configs, application ecosystem, and finally a single-command bootstrap.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Foundation** - Core chezmoi infrastructure with device detection
- [ ] **Phase 2: Secrets** - 1Password integration for all sensitive data
- [ ] **Phase 3: Core Configs** - Shell and Git configuration with templating
- [ ] **Phase 4: App Ecosystem** - Application configs, CLI tools, and package management
- [ ] **Phase 5: Bootstrap** - Single-command fresh machine setup

## Phase Details

### Phase 1: Foundation
**Goal**: Chezmoi infrastructure that prompts for device identity and conditionally manages files
**Depends on**: Nothing (first phase)
**Requirements**: INFRA-01, INFRA-02, INFRA-03, INFRA-04
**Success Criteria** (what must be TRUE):
  1. Running `chezmoi init` prompts for hostname, email, and device type (work/personal/minimal)
  2. Files are conditionally ignored based on OS (darwin/linux) and device type
  3. Source state is cleanly separated from repository metadata via `.chezmoiroot`
  4. `add.secrets = "error"` is configured to prevent accidental secret commits
**Plans**: TBD

Plans:
- [ ] 01-01: TBD

### Phase 2: Secrets
**Goal**: 1Password integration that provides secrets to all templated configs
**Depends on**: Phase 1
**Requirements**: SECR-01, SECR-02, SECR-03, SECR-04
**Success Criteria** (what must be TRUE):
  1. Templates can retrieve secrets via `onepasswordRead` function
  2. SSH connections work using 1Password SSH agent (no local key files)
  3. Git commits are signed via 1Password
  4. Running `chezmoi diff` shows no secrets in plain text
**Plans**: TBD

Plans:
- [ ] 02-01: TBD

### Phase 3: Core Configs
**Goal**: Shell and Git configs that provide the daily driver dev environment
**Depends on**: Phase 2
**Requirements**: SHELL-01, SHELL-02, SHELL-03, SHELL-04, SHELL-05, GIT-01, GIT-02, GIT-03, GIT-04
**Success Criteria** (what must be TRUE):
  1. New shell opens with zsh, oh-my-zsh, starship prompt, and all aliases working
  2. Git shows correct email (work on work device, personal elsewhere)
  3. `it` tool wrapper exists only on work device
  4. All shell integrations work (zoxide, fzf keybindings)
**Plans**: TBD

Plans:
- [ ] 03-01: TBD

### Phase 4: App Ecosystem
**Goal**: Full application configs and package installation for complete dev environment
**Depends on**: Phase 3
**Requirements**: APP-01, APP-02, APP-03, APP-04, APP-05, APP-06, CLI-01, CLI-02, PKG-01, PKG-02, PKG-03, PKG-04
**Success Criteria** (what must be TRUE):
  1. Nvim opens with LazyVim and all customizations working
  2. Ghostty, htop, gh CLI are configured correctly
  3. Kanata config is present on macOS devices (not auto-installed)
  4. Running `chezmoi apply` installs all packages via Brewfile (macOS) or pacman script (Arch)
  5. CLI tools (bat, eza, fd, fzf, jq, lazygit, rg, zoxide) have correct configs
**Plans**: TBD

Plans:
- [ ] 04-01: TBD

### Phase 5: Bootstrap
**Goal**: Single-command setup for fresh machines
**Depends on**: Phase 4
**Requirements**: BOOT-01, BOOT-02, BOOT-03, BOOT-04
**Success Criteria** (what must be TRUE):
  1. Single command (curl | sh or similar) bootstraps a fresh machine
  2. Bootstrap correctly detects macOS vs Linux and runs appropriate setup
  3. Bootstrap installs chezmoi if not present
  4. After bootstrap completes, machine is fully configured (ready to dev)
**Plans**: TBD

Plans:
- [ ] 05-01: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 -> 2 -> 3 -> 4 -> 5

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation | 0/TBD | Not started | - |
| 2. Secrets | 0/TBD | Not started | - |
| 3. Core Configs | 0/TBD | Not started | - |
| 4. App Ecosystem | 0/TBD | Not started | - |
| 5. Bootstrap | 0/TBD | Not started | - |

---
*Roadmap created: 2026-01-18*
*Last updated: 2026-01-18*
