# Dotfiles

## What This Is

A Chezmoi-managed dotfiles repository that maintains consistent dev environments across 4 devices: 2 macOS laptops, a CachyOS desktop (M7), and Proxmox homelab VMs. Enables rapid machine bootstrap with device-appropriate configs, packages, and tooling.

## Core Value

Fresh machine → productive dev environment in minutes, not hours.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Chezmoi manages all dotfiles with device-specific templating
- [ ] Brewfile handles macOS package installation
- [ ] Shell script handles Arch/CachyOS package installation
- [ ] Minimal bootstrap script for Proxmox VMs
- [ ] Git config templated for work vs personal email
- [ ] Kanata config stored but manually installed (macOS only)
- [ ] 1Password integration for secrets (no secrets in repo)
- [ ] `it` tool wrapper included only on work device
- [ ] Bootstrap script detects OS and runs appropriate setup

### Out of Scope

- Zed config — just testing, not primary editor
- Helix config — just testing, not primary editor
- Nix/Home Manager — deferred, may revisit later
- Full setup for Proxmox VMs — minimal only
- GUI app management beyond Brewfile casks
- Automatic kanata installation — manual only

## Context

**Existing configs to migrate:**
- nvim: LazyVim + custom lua/after at ~/.config/nvim/
- zsh: oh-my-zsh + plugins at ~/.zshrc, ~/.zprofile
- starship: Custom prompt at ~/.config/starship.toml
- ghostty: ~/.config/ghostty/config
- git: ~/.gitconfig (1Password SSH signing)
- gh: ~/.config/gh/
- kanata: ~/.config/kanata/kanata.kbd
- htop: ~/.config/htop/

**CLI tools (via Homebrew):**
bat, bottom, eza, fd, fzf, jq, k9s, lazygit, ripgrep, zoxide, go, helm, kind, httpie, awscli

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
| Chezmoi over Nix | Simpler to start, LLM-friendly, can migrate to Nix later | — Pending |
| 1Password for secrets | Already in use, good CLI integration | — Pending |
| Minimal Proxmox setup | VMs are ephemeral, full setup overkill | — Pending |
| Kanata manual install | Only needed on macbooks, opt-in reduces complexity | — Pending |

---
*Last updated: 2025-01-18 after initialization*
