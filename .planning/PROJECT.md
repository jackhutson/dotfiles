# Dotfiles

## What This Is

A Chezmoi-managed dotfiles repository that maintains consistent dev environments across 4 devices: 2 macOS laptops, a CachyOS desktop (M7), and Proxmox homelab VMs. Enables rapid machine bootstrap with device-appropriate configs, packages, and tooling.

## Core Value

Fresh machine → productive dev environment in minutes, not hours.

## Current Milestone: v1.1 — Make It Actually Work

**Goal:** Fix v1 gaps so bootstrap actually delivers "productive in minutes" — not "productive after debugging."

**Target fixes:**
- Sync configs from working machine (v1 had stale snapshots)
- Complete kanata setup (launchd plist + clear instructions)
- Add Claude Code installation to post-apply guidance
- Add `.claude` config directory (MCPs, settings, plugins)
- Fix verification script (no false positives, actionable output)
- Clear post-apply "next steps" output

## v1 State

**Shipped:** 2026-01-19
**LOC:** ~1,634 lines of config
**Stack:** Chezmoi, zsh, oh-my-zsh, starship, nvim/LazyVim, 1Password CLI

**v1 issues discovered on personal macbook:**
- Kanata config present but no launchd service — keyboard unusable until manual setup
- Claude Code alias invalid for target system — had to install manually and comment out alias
- Starship config regressed to buggy version — not current working config
- 1Password verification gave false warning — no actionable info, eroded trust
- Some configs were stale snapshots, not current working versions

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

- [ ] Configs match current working machine (not stale snapshots)
- [ ] Kanata launchd plist created for macOS
- [ ] Post-apply output shows clear "next steps" with copy-paste commands
- [ ] Claude Code installed via official method, no broken alias
- [ ] `.claude` config directory synced (MCPs, settings, custom commands)
- [ ] Verification script gives actionable output (no false positives)

### Out of Scope

- Zed config — just testing, not primary editor
- Helix config — just testing, not primary editor
- Nix/Home Manager — deferred, may revisit later
- Full setup for Proxmox VMs — minimal only (v2 consideration)
- GUI app management beyond Brewfile casks
- Automatic kanata installation — manual only

## Context

**Migrated configs (v1 + v1.1):**
- nvim: LazyVim + 13 custom plugins
- zsh: oh-my-zsh + 4 custom plugins (syntax-highlighting, autosuggestions, you-should-use, completions)
- starship: Catppuccin Mocha theme prompt
- ghostty: Catppuccin Mocha terminal config
- git: Templated email + 1Password SSH signing
- gh: CLI config with nvim editor
- kanata: Home row mods + nav/symbol layers (macOS only) + launchd plist (v1.1)
- htop: Custom layout
- CLI tools: bat, fd, ripgrep, lazygit, fzf, eza, zoxide
- claude: MCP servers, settings, custom commands (v1.1)

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
| Chezmoi over Nix | Simpler to start, LLM-friendly, can migrate to Nix later | ⚠️ Revisit — v1 had stale config issues, Nix may be v2 |
| 1Password for secrets | Already in use, good CLI integration | ⚠️ Revisit — verification has false positives |
| Minimal Proxmox setup | VMs are ephemeral, full setup overkill | — Pending (deferred to v2) |
| Kanata manual install | Only needed on macbooks, opt-in reduces complexity | ⚠️ Revisit — need launchd plist, clearer instructions |
| Y/n prompt over choice menu | User feedback: choice menu auto-selects on partial match | ✓ Good — explicit Y/n clearer |
| Archive type for oh-my-zsh | Avoid conflicts with oh-my-zsh auto-update | ✓ Good — chezmoi controls updates |
| run_after verification script | Surface 1Password misconfigs on every apply | ⚠️ Revisit — false positives erode trust |
| Discovery-based migration | Capture configs from existing machine | ⚠️ Revisit — captured stale versions, not current |
| Post-apply guidance | Clear next steps after chezmoi apply | — Pending (v1.1 adds this) |

---
*Last updated: 2026-01-20 after v1.1 milestone start*
