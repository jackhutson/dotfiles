# Milestone v1: MVP

**Status:** ✅ SHIPPED 2026-01-19
**Phases:** 1-5
**Total Plans:** 11

## Overview

This roadmap transforms a collection of existing configs into a Chezmoi-managed dotfiles repository that bootstraps 4 devices (2 macOS, 1 CachyOS, Linux VMs) to a productive dev environment in minutes. The journey starts with core infrastructure and 1Password integration (the critical path), then adds shell/git configs, application ecosystem, and finally a single-command bootstrap.

## Phases

### Phase 1: Foundation

**Goal**: Chezmoi infrastructure that prompts for device identity and conditionally manages files
**Depends on**: Nothing (first phase)
**Requirements**: INFRA-01, INFRA-02, INFRA-03, INFRA-04
**Plans**: 1 plan

**Success Criteria:**
1. Running `chezmoi init` prompts for device type (work/personal)
2. Files are conditionally ignored based on OS (darwin/linux) and device type
3. Source state is cleanly separated from repository metadata via `.chezmoiroot`
4. `add.secrets = "error"` is configured to prevent accidental secret commits

Plans:
- [x] 01-01-PLAN.md — Create chezmoi infrastructure with device type prompting

**Completed:** 2026-01-18

### Phase 2: Secrets

**Goal**: 1Password integration that provides secrets to all templated configs
**Depends on**: Phase 1
**Requirements**: SECR-01, SECR-02, SECR-03, SECR-04
**Plans**: 2 plans

**Success Criteria:**
1. Templates can retrieve secrets via `onepasswordRead` function
2. SSH connections work using 1Password SSH agent (no local key files)
3. Git commits are signed via 1Password
4. Running `chezmoi diff` shows no secrets in plain text

Plans:
- [x] 02-01-PLAN.md — SSH and Git config with 1Password integration
- [x] 02-02-PLAN.md — Verification script and end-to-end confirmation

**Completed:** 2026-01-19

### Phase 3: Core Configs

**Goal**: Shell and Git configs that provide the daily driver dev environment
**Depends on**: Phase 2
**Requirements**: SHELL-01, SHELL-02, SHELL-03, SHELL-04, SHELL-05, GIT-01, GIT-02, GIT-03, GIT-04
**Plans**: 3 plans

**Success Criteria:**
1. New shell opens with zsh, oh-my-zsh, starship prompt, and all aliases working
2. Git shows correct email (work on work device, personal elsewhere)
3. `it` tool wrapper exists only on work device
4. All shell integrations work (zoxide, fzf keybindings)

Plans:
- [x] 03-01-PLAN.md — Create oh-my-zsh external dependencies and templated zshrc
- [x] 03-02-PLAN.md — Create static shell configs (starship, zprofile, aliases)
- [x] 03-03-PLAN.md — Update .chezmoiignore and add work-only _it completion

**Completed:** 2026-01-19

### Phase 4: App Ecosystem

**Goal**: Full application configs and package installation for complete dev environment
**Depends on**: Phase 3
**Requirements**: APP-01, APP-02, APP-03, APP-04, APP-05, APP-06, CLI-01, CLI-02, PKG-01, PKG-02, PKG-03, PKG-04
**Plans**: 4 plans

**Success Criteria:**
1. Nvim opens with LazyVim and all customizations working
2. Ghostty, htop, gh CLI are configured correctly
3. Kanata config is present on macOS devices (not auto-installed)
4. Running `chezmoi apply` installs all packages via Brewfile (macOS) or pacman script (Arch)
5. CLI tools (bat, eza, fd, fzf, jq, lazygit, rg, zoxide) have correct configs

Plans:
- [x] 04-01-PLAN.md — Create package management infrastructure (Brewfile + pacman scripts)
- [x] 04-02-PLAN.md — Migrate application configs (nvim, ghostty, htop, gh, kanata)
- [x] 04-03-PLAN.md — Configure CLI tools (bat, fd, ripgrep, lazygit, zshrc env vars)
- [x] 04-04-PLAN.md — Verification and human approval

**Completed:** 2026-01-18

### Phase 5: Bootstrap

**Goal**: Single-command setup for fresh machines
**Depends on**: Phase 4
**Requirements**: BOOT-01, BOOT-02, BOOT-03, BOOT-04
**Plans**: 1 plan

**Success Criteria:**
1. Single command (curl | sh or similar) bootstraps a fresh machine
2. Bootstrap correctly detects macOS vs Linux and runs appropriate setup
3. Bootstrap installs chezmoi if not present
4. After bootstrap completes, machine is fully configured (ready to dev)

Plans:
- [x] 05-01-PLAN.md — Create bootstrap script and summary file

**Completed:** 2026-01-19

---

## Milestone Summary

**Key Decisions:**
- Chezmoi over Nix — simpler to start, LLM-friendly
- 1Password for secrets — already in use, good CLI integration
- Y/n prompt over choice menu — user feedback, explicit is clearer
- Archive type for oh-my-zsh — avoid auto-update conflicts
- run_after verification script — catches misconfigs on every apply

**Issues Resolved:**
- None — clean execution

**Issues Deferred:**
- Proxmox VM minimal setup (deferred to v2)
- macOS defaults script (deferred to v2)
- README documentation (deferred to v2)

**Technical Debt Incurred:**
- None identified

---

*For current project status, see .planning/PROJECT.md*
*Archived: 2026-01-19 as part of v1 milestone completion*
