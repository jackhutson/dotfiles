# Stack Research: Cross-Platform Dotfiles Management

**Domain:** Chezmoi-based dotfiles management (macOS + Linux)
**Researched:** 2026-01-18
**Overall Confidence:** HIGH

## Executive Summary

The 2025 standard stack for cross-platform dotfiles management is well-established and stable. Chezmoi v2.69.3 is the clear choice for dotfiles management, with native 1Password CLI integration for secrets. Age encryption is available but unnecessary when using 1Password. The stack is straightforward: Chezmoi handles templating and orchestration, 1Password provides secrets, and platform-specific package managers (Homebrew/pacman) handle software installation via `run_onchange_` scripts.

## Recommended Stack

### Core: Dotfiles Management

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| **Chezmoi** | 2.69.3 | Dotfiles management | Industry standard. Single binary, no dependencies. Native templating, password manager integration, cross-platform. Written in Go, actively maintained (released 2026-01-16). | HIGH |

**Installation:**
- macOS: `brew install chezmoi`
- Arch Linux: `pacman -S chezmoi`
- Fresh machine bootstrap: `sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME`

**Source:** [chezmoi.io/install](https://www.chezmoi.io/install/), [GitHub releases](https://github.com/twpayne/chezmoi/releases)

### Core: Secrets Management

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| **1Password CLI (op)** | 2.32.0 | Secrets injection | You already have 1Password. Native chezmoi integration via `onepasswordRead`. Biometric auth on macOS, no additional key management. Secrets never stored in dotfiles repo. | HIGH |

**Key Configuration:**
```toml
# ~/.config/chezmoi/chezmoi.toml
[onepassword]
    mode = "account"  # Uses desktop app integration
    prompt = true     # Interactive sign-in when needed
```

**Template Usage:**
```
# In any .tmpl file
export API_KEY='{{ onepasswordRead "op://Personal/api-key/credential" }}'
```

**Source:** [chezmoi.io/user-guide/password-managers/1password](https://www.chezmoi.io/user-guide/password-managers/1password/)

### Supporting: Encryption (Optional)

| Technology | Version | Purpose | Why | Confidence |
|------------|---------|---------|-----|------------|
| **Age** | latest | File encryption | Only needed if you want to store encrypted files directly in repo instead of fetching from 1Password. Simpler than GPG, modern defaults. Built-in chezmoi support. | MEDIUM |

**When to use Age:**
- Secrets that should exist even when 1Password is unavailable (rare)
- Non-secret sensitive data (personal notes, etc.)
- Environments where 1Password desktop app isn't installed

**When NOT to use Age:**
- API keys, credentials (use 1Password instead)
- Any secret that benefits from 1Password's rotation/sharing features

**Source:** [chezmoi.io/user-guide/encryption/age](https://www.chezmoi.io/user-guide/encryption/age/)

### Supporting: Package Management

| Technology | Purpose | Platform | Why | Confidence |
|------------|---------|----------|-----|------------|
| **Homebrew + Brewfile** | Package declaration | macOS | Declarative, reproducible. `brew bundle` integrates cleanly with chezmoi `run_onchange_` scripts. | HIGH |
| **pacman** | Package management | Arch/CachyOS | Native package manager. Use shell script with package list for automation. | HIGH |

**Source:** [chezmoi.io/user-guide/machines/macos](https://www.chezmoi.io/user-guide/machines/macos/)

### Supporting: Templating Data

| Technology | Purpose | Why | Confidence |
|------------|---------|-----|------------|
| **`.chezmoidata/` directory** | Machine-agnostic data | YAML/JSON files for package lists, shared configuration. Changes trigger `run_onchange_` scripts. | HIGH |
| **`chezmoi.toml` [data] section** | Machine-specific data | Email, hostname-specific flags, device type. Set during `chezmoi init`. | HIGH |

## Integration Points

### How Components Work Together

```
                    +------------------+
                    |   GitHub Repo    |
                    |   (dotfiles)     |
                    +--------+---------+
                             |
                    chezmoi init --apply
                             |
                             v
+-------------------+       +------------------+
| 1Password Desktop |<----->|     chezmoi      |
| (biometric auth)  |       | (orchestration)  |
+-------------------+       +--------+---------+
                                     |
              +----------------------+----------------------+
              |                      |                      |
              v                      v                      v
    +------------------+   +------------------+   +------------------+
    |    Templates     |   | run_onchange_    |   |   .chezmoiignore |
    | (.chezmoi.os,    |   | scripts          |   | (platform-       |
    |  .chezmoi.       |   | (Brewfile,       |   |  specific        |
    |  hostname)       |   |  pacman)         |   |  exclusions)     |
    +------------------+   +------------------+   +------------------+
```

### Templating Flow

1. **Machine detection** via built-in variables:
   - `.chezmoi.os` (darwin, linux)
   - `.chezmoi.hostname` (for device-specific config)
   - `.chezmoi.arch` (amd64, arm64)

2. **Custom data** in `~/.config/chezmoi/chezmoi.toml`:
   ```toml
   [data]
       email = "jack@work.com"
       isWorkMachine = true
       deviceType = "laptop"  # or "desktop"
   ```

3. **Conditional content** in templates:
   ```
   {{- if eq .chezmoi.os "darwin" }}
   # macOS specific config
   {{- else if eq .chezmoi.os "linux" }}
   # Linux specific config
   {{- end }}

   {{- if .isWorkMachine }}
   # Work tools
   {{- end }}
   ```

### Package Installation Flow

**macOS (Brewfile):**
```bash
# run_onchange_before_install-packages-darwin.sh.tmpl
{{- if eq .chezmoi.os "darwin" -}}
#!/bin/bash
# Brewfile hash: {{ include "dot_Brewfile" | sha256sum }}
brew bundle --file={{ .chezmoi.sourceDir }}/dot_Brewfile
{{- end }}
```

**Arch Linux:**
```bash
# run_onchange_before_install-packages-linux.sh.tmpl
{{- if eq .chezmoi.os "linux" -}}
#!/bin/bash
# packages.yaml hash: {{ include ".chezmoidata/packages.yaml" | sha256sum }}
sudo pacman -S --needed $(yq '.arch.packages[]' {{ .chezmoi.sourceDir }}/.chezmoidata/packages.yaml | tr '\n' ' ')
{{- end }}
```

### Secrets Flow (1Password)

1. Store secret in 1Password (vault: Personal, item: api-key)
2. Reference in template: `{{ onepasswordRead "op://Personal/api-key/credential" }}`
3. On `chezmoi apply`:
   - chezmoi calls `op read op://Personal/api-key/credential`
   - 1Password prompts for biometric/password if session expired
   - Secret injected into generated file
4. Secret never stored in source repo

## What NOT to Use

### Do NOT Use: GNU Stow

| Issue | Details |
|-------|---------|
| **No templating** | Cannot handle machine-to-machine differences without separate branches |
| **Symlink-only** | Difficult to migrate away from; requires manual cleanup |
| **No secrets support** | Would need separate tooling for credentials |
| **No cross-platform** | Struggles with files in different locations per OS |

**Source:** [Community comparison discussion](https://news.ycombinator.com/item?id=39975247)

### Do NOT Use: YADM

| Issue | Details |
|-------|---------|
| **Jinja templating dependency** | Uses third-party tools (envtpl, j2cli) that are poorly maintained |
| **Git wrapper complexity** | "Just a Git wrapper" - you need to understand Git internals |
| **Worse cross-OS support** | `##os.Linux` syntax is clunky compared to chezmoi templates |

Chezmoi's Go text/template is built-in and will always be maintained.

**Source:** [Community comparison](https://biggo.com/news/202412191324_dotfile-management-tools-comparison)

### Do NOT Use: Age for 1Password-Available Secrets

| Issue | Details |
|-------|---------|
| **Key management overhead** | Age requires managing a private key; 1Password already handles this |
| **No rotation** | Age-encrypted secrets require manual re-encryption to rotate |
| **Redundant** | 1Password already provides encryption at rest |

Use 1Password for secrets. Reserve Age only for scenarios where 1Password is unavailable.

### Do NOT Use: GPG (for encryption)

| Issue | Details |
|-------|---------|
| **Complexity** | GPG key management is notoriously difficult |
| **Setup time** | "Setting up GPG keys on YubiKeys previously took several hours" vs trivial Age setup |
| **Attack surface** | More configuration options = more ways to weaken encryption |

If you need encryption beyond 1Password, use Age.

**Source:** [Switching from GPG to age](https://luke.hsiao.dev/blog/gpg-to-age/)

### Do NOT Use: Nix Home Manager (for this use case)

| Issue | Details |
|-------|---------|
| **Complexity** | Steep learning curve for declarative configuration |
| **Portability** | Works best on NixOS; quirky on macOS and other Linux distros |
| **Overkill** | Full functional programming language for dotfiles is unnecessary when chezmoi templating suffices |

Nix is powerful but adds complexity your use case doesn't require.

### Do NOT Use: `external_` for Large Archives

| Issue | Details |
|-------|---------|
| **Performance** | chezmoi validates external contents on every `diff`, `apply`, `verify` |
| **Slow operations** | Large externals make routine commands slow |

For large archives, use `run_onchange_` scripts to download and unpack once.

**Source:** [chezmoi.io/user-guide/include-files-from-elsewhere](https://www.chezmoi.io/user-guide/include-files-from-elsewhere/)

## Version Pinning Strategy

| Tool | Pin Strategy | Why |
|------|--------------|-----|
| **Chezmoi** | Latest stable | Actively maintained, backward compatible, no breaking changes in minor versions |
| **1Password CLI** | Latest stable | Security tool - keep updated |
| **Age** | Latest stable | If used. Stable, minimal changes |

No strict version pinning needed. These tools follow semantic versioning and maintain backward compatibility.

## Installation Commands

### macOS (Fresh Machine)

```bash
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply $GITHUB_USERNAME

# chezmoi's run_onchange_ scripts will handle:
# - Installing 1Password CLI via Brewfile
# - Installing other packages via Brewfile
```

### Arch Linux/CachyOS (Fresh Machine)

```bash
# 1. Install chezmoi
sudo pacman -S chezmoi

# 2. Apply dotfiles
chezmoi init --apply $GITHUB_USERNAME

# chezmoi's run_onchange_ scripts will handle:
# - Installing packages via pacman
# - Any AUR packages via yay/paru
```

### 1Password CLI Setup (Post-Install)

```bash
# If not using biometric auth:
op account add --address my.1password.com --email your@email.com
eval $(op signin --account my)

# With biometric auth (macOS with 1Password desktop):
# Just run any op command - it will prompt for Touch ID
```

## Confidence Assessment

| Component | Confidence | Rationale |
|-----------|------------|-----------|
| Chezmoi v2.69.3 | HIGH | Verified via official GitHub releases (2026-01-16 release) |
| 1Password CLI integration | HIGH | Verified via official chezmoi documentation |
| Age recommendation | MEDIUM | Based on community consensus and chezmoi FAQ; you may not need it with 1Password |
| run_onchange_ pattern | HIGH | Official chezmoi documentation pattern |
| Anti-recommendations | HIGH | Based on documented limitations and community experience |

## Sources

### Official Documentation
- [chezmoi.io](https://www.chezmoi.io/) - Official chezmoi documentation
- [chezmoi GitHub releases](https://github.com/twpayne/chezmoi/releases) - Version verification
- [1Password CLI](https://developer.1password.com/docs/cli/) - 1Password CLI documentation
- [chezmoi 1Password integration](https://www.chezmoi.io/user-guide/password-managers/1password/)
- [chezmoi Age encryption](https://www.chezmoi.io/user-guide/encryption/age/)
- [chezmoi machine differences](https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/)
- [chezmoi scripts](https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/)

### Community References
- [Switching from GPG to age](https://luke.hsiao.dev/blog/gpg-to-age/)
- [Dotfile tools comparison](https://biggo.com/news/202412191324_dotfile-management-tools-comparison)
- [chezmoi comparison table](https://www.chezmoi.io/comparison-table/)
