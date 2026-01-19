# Dotfiles

## What This Is

A Chezmoi-managed dotfiles repository that maintains consistent dev environments across 4 devices: 2 macOS laptops, a CachyOS desktop (M7), and Proxmox homelab VMs. Enables rapid machine bootstrap with device-appropriate configs, packages, and tooling.

## Core Value

Fresh machine → productive dev environment in minutes, not hours.

## Current State (v1 shipped)

**Shipped:** 2026-01-19
**LOC:** ~1,634 lines of config
**Stack:** Chezmoi, zsh, oh-my-zsh, starship, nvim/LazyVim, 1Password CLI

v1 delivers the core goal: single-command bootstrap for all 4 device types with full dev environment.

## Requirements

### Validated

- ✓ Chezmoi manages all dotfiles with device-specific templating — v1
- ✓ Brewfile handles macOS package installation — v1
- ✓ Shell script handles Arch/CachyOS package installation — v1
- ✓ Git config templated for work vs personal email — v1
- ✓ Kanata config stored but manually installed (macOS only) — v1
- ✓ 1Password integration for secrets (no secrets in repo) — v1
- ✓ `it` tool wrapper included only on work device — v1
- ✓ Bootstrap script detects OS and runs appropriate setup — v1

### Active

(None — v1 complete, define new requirements for v1.1)

### Out of Scope

- Zed config — just testing, not primary editor
- Helix config — just testing, not primary editor
- Nix/Home Manager — deferred, may revisit later
- Full setup for Proxmox VMs — minimal only (v2 consideration)
- GUI app management beyond Brewfile casks
- Automatic kanata installation — manual only

## Context

**Migrated configs (v1):**
- nvim: LazyVim + 13 custom plugins
- zsh: oh-my-zsh + 4 custom plugins (syntax-highlighting, autosuggestions, you-should-use, completions)
- starship: Catppuccin Mocha theme prompt
- ghostty: Catppuccin Mocha terminal config
- git: Templated email + 1Password SSH signing
- gh: CLI config with nvim editor
- kanata: Home row mods + nav/symbol layers (macOS only)
- htop: Custom layout
- CLI tools: bat, fd, ripgrep, lazygit, fzf, eza, zoxide

**CLI tools managed (via packages.yaml):**
macOS: bat, bottom, eza, fd, fzf, jq, k9s, lazygit, ripgrep, zoxide, go, helm, kind, httpie, awscli, starship, oven-sh/bun/bun
Linux: bat, bottom, eza, fd, fzf, jq, k9s, lazygit, ripgrep, zoxide, go, starship, neovim

**Device matrix:**
| Device | OS | Git Email | Kanata | it tool | Setup Level |
|--------|----|-----------|---------|---------| -----------|
| Work macbook | macOS | work | stored | yes | full |
| Personal macbook | macOS | personal | stored | no | full |
| M7 | CachyOS | personal | no | no | full |
| Proxmox VMs | Linux | personal | no | no | minimal |

## Constraints

- **Package managers**: Homebrew on macOS, pacman on Arch — no Nix
- **Secrets**: Must use 1Password, never commit secrets
- **Compatibility**: macOS (latest) and Linux only, no Windows
- **Kanata**: Config stored but installation is manual/opt-in

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Chezmoi over Nix | Simpler to start, LLM-friendly, can migrate to Nix later | ✓ Good — achieved goal in 2 days |
| 1Password for secrets | Already in use, good CLI integration | ✓ Good — verification script catches misconfigs |
| Minimal Proxmox setup | VMs are ephemeral, full setup overkill | — Pending (deferred to v2) |
| Kanata manual install | Only needed on macbooks, opt-in reduces complexity | ✓ Good — config stored, install manual |
| Y/n prompt over choice menu | User feedback: choice menu auto-selects on partial match | ✓ Good — explicit Y/n clearer |
| Archive type for oh-my-zsh | Avoid conflicts with oh-my-zsh auto-update | ✓ Good — chezmoi controls updates |
| run_after verification script | Surface 1Password misconfigs on every apply | ✓ Good — catches issues early |

---
*Last updated: 2026-01-19 after v1 milestone*
