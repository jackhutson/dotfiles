# Architecture Research: Chezmoi Dotfiles Repository

**Domain:** Multi-OS, multi-device dotfiles management with Chezmoi
**Researched:** 2026-01-18
**Confidence:** HIGH (based on official Chezmoi documentation)

## Directory Structure

### Recommended Layout

For a complex multi-OS repository with configs, scripts, and package management, use `.chezmoiroot` to separate source state from repository metadata:

```
.dotfiles/
├── .chezmoiroot                    # Contains: "home"
├── .git/
├── .planning/                      # GSD planning (ignored by chezmoi)
├── README.md                       # Repository documentation
├── scripts/                        # Utility scripts (not chezmoi-managed)
│   └── utils.sh                    # Shared functions for run_ scripts
│
└── home/                           # Source state root (chezmoi manages this)
    ├── .chezmoi.toml.tmpl          # Config template (prompts for device-specific data)
    ├── .chezmoidata.toml           # Static data available to all templates
    ├── .chezmoiignore              # Files to ignore (with templating)
    ├── .chezmoiexternal.toml       # External dependencies (fonts, plugins)
    ├── .chezmoitemplates/          # Reusable template fragments
    │   ├── git-user-config         # Shared git config snippet
    │   └── shell-aliases           # Shared alias definitions
    │
    ├── .chezmoiscripts/            # All run_ scripts organized here
    │   ├── darwin/                 # macOS-only scripts
    │   │   └── run_onchange_darwin-defaults.sh.tmpl
    │   ├── linux/                  # Linux-only scripts
    │   │   └── run_onchange_arch-packages.sh.tmpl
    │   ├── run_once_before_install-1password-cli.sh.tmpl
    │   ├── run_once_before_install-homebrew.sh.tmpl
    │   └── run_onchange_after_install-packages.sh.tmpl
    │
    ├── dot_config/                 # ~/.config/ directory
    │   ├── nvim/                   # Neovim config (exact_ if needed)
    │   ├── ghostty/
    │   ├── starship.toml.tmpl
    │   └── htop/
    │
    ├── dot_gitconfig.tmpl          # Templated for email variation
    ├── dot_zshrc.tmpl              # Shell config with conditionals
    ├── private_dot_ssh/            # SSH config (private permissions)
    │   └── config.tmpl
    │
    └── Brewfile.tmpl               # macOS package list (templated)
```

### Key Structural Decisions

**Use `.chezmoiroot`:** Setting `home` as the source directory root keeps repository metadata (README, scripts/, .planning/) separate from managed dotfiles. This is the recommended pattern for complex repositories.

**Group scripts in `.chezmoiscripts/`:** Centralizes all run_ scripts. Use subdirectories for OS-specific scripts that won't run on other platforms.

**Use `dot_config/` for XDG configs:** Maps to `~/.config/`, the standard location for application configs.

**Keep utility scripts outside source state:** Place shared shell functions in `scripts/` at repository root, source them using `${CHEZMOI_WORKING_TREE}/scripts/utils.sh`.

## Naming Conventions

### File Prefixes (Order Matters)

Prefixes must appear in this specific order:

| Prefix | Purpose | Example |
|--------|---------|---------|
| `external_` | Mark directory as externally managed | `external_dot_oh-my-zsh/` |
| `exact_` | Remove unmanaged files in directory | `exact_dot_config/nvim/` |
| `remove_` | Delete target if exists | `remove_dot_old_config` |
| `create_` | Create only if missing | `create_dot_env` |
| `modify_` | Run as modification script | `modify_dot_npmrc` |
| `run_` | Execute as script | `run_install.sh` |
| `symlink_` | Create symbolic link | `symlink_dot_vimrc` |
| `encrypted_` | Encrypt in source | `encrypted_private_dot_ssh_key` |
| `private_` | Remove group/world permissions | `private_dot_ssh/` |
| `readonly_` | Remove write permissions | `readonly_dot_profile` |
| `empty_` | Preserve empty file | `empty_dot_keep` |
| `executable_` | Add execute permission | `executable_dot_local/bin/script` |
| `once_` | Run script once per content hash | `run_once_install.sh` |
| `onchange_` | Run when content changes | `run_onchange_packages.sh` |
| `before_` | Run before file updates | `run_once_before_deps.sh` |
| `after_` | Run after file updates | `run_onchange_after_reload.sh` |
| `dot_` | Prepend dot to filename | `dot_gitconfig` |
| `literal_` | Stop prefix parsing | `literal_run_test.sh` |

### File Suffixes

| Suffix | Purpose | Example |
|--------|---------|---------|
| `.tmpl` | Process as Go template | `dot_gitconfig.tmpl` |
| `.literal` | Stop suffix parsing | `config.toml.literal` |
| `.age` | Age-encrypted file | `private_key.age` |
| `.asc` | GPG-encrypted file | `private_key.asc` |

### Common Naming Patterns

```
# Basic dotfile
dot_zshrc                          -> ~/.zshrc

# Templated dotfile
dot_gitconfig.tmpl                 -> ~/.gitconfig (processed)

# Private directory with templates
private_dot_ssh/config.tmpl        -> ~/.ssh/config (mode 600)

# Executable script in bin
dot_local/bin/executable_myscript  -> ~/.local/bin/myscript (mode 755)

# Run-once setup script
run_once_before_install-homebrew.sh.tmpl

# Run-on-change package installer
run_onchange_after_install-packages.sh.tmpl

# Encrypted private file
encrypted_private_dot_env          -> ~/.env (decrypted, mode 600)
```

## Template Organization

### Configuration Data Hierarchy

```
home/
├── .chezmoi.toml.tmpl      # Generated per-machine (prompts user)
├── .chezmoidata.toml       # Static data for all machines
└── .chezmoidata/           # Additional data files (optional)
    ├── packages.toml       # Package lists
    └── aliases.toml        # Shell aliases
```

**`.chezmoi.toml.tmpl`** - Machine-specific config generated on init:

```toml
{{- $email := promptStringOnce . "email" "Git email address" -}}
{{- $isWork := promptBoolOnce . "isWork" "Is this a work machine" -}}
{{- $isMinimal := promptBoolOnce . "isMinimal" "Minimal install (VM/server)" -}}

[data]
    email = {{ $email | quote }}
    isWork = {{ $isWork }}
    isMinimal = {{ $isMinimal }}

[onepassword]
    mode = "account"
```

**`.chezmoidata.toml`** - Static data available everywhere:

```toml
[packages.common]
    brew = ["git", "neovim", "starship", "gh", "htop"]

[packages.full]
    brew = ["docker", "kubectl", "terraform"]
```

### Reusable Templates

Place in `.chezmoitemplates/` for inclusion:

```
.chezmoitemplates/
├── git-user-config         # {{ template "git-user-config" . }}
├── shell-path-setup        # Common PATH configuration
└── tool-aliases            # Shared CLI aliases
```

**Example: git-user-config**
```
[user]
    name = Jack Hutson
    email = {{ .email }}
{{- if .isWork }}
    signingkey = {{ onepasswordRead "op://Work/GPG Key/public key" }}
{{- end }}
```

**Usage in `dot_gitconfig.tmpl`:**
```
{{ template "git-user-config" . }}

[core]
    editor = nvim
```

### Conditional Content Patterns

**OS-specific blocks:**
```
{{- if eq .chezmoi.os "darwin" }}
# macOS specific
{{- else if eq .chezmoi.os "linux" }}
# Linux specific
{{- end }}
```

**Device-type conditionals:**
```
{{- if not .isMinimal }}
# Full installation extras
{{- end }}

{{- if .isWork }}
# Work-only configuration
{{- end }}
```

**Hostname-based:**
```
{{- if eq .chezmoi.hostname "macbook-pro" }}
# Specific machine config
{{- end }}
```

## Script Organization

### Script Categories and Patterns

**1. Bootstrap Scripts (run_once_before_)**

Run once, before file deployment. Use for installing prerequisites:

```bash
# run_once_before_00-install-prerequisites.sh.tmpl
{{- if eq .chezmoi.os "darwin" }}
#!/bin/bash
# Install Homebrew if missing
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
{{- end }}
```

**2. Package Installation (run_onchange_after_)**

Run when package list changes, after files deployed:

```bash
# run_onchange_after_install-packages.sh.tmpl
{{- if eq .chezmoi.os "darwin" }}
#!/bin/bash
# Brewfile hash: {{ include "Brewfile.tmpl" . | sha256sum }}
brew bundle --file={{ .chezmoi.homeDir }}/Brewfile
{{- end }}
```

The hash comment triggers re-run when Brewfile changes.

**3. Config Application (run_onchange_after_)**

Apply config changes that require commands:

```bash
# run_onchange_after_apply-macos-defaults.sh.tmpl
{{- if eq .chezmoi.os "darwin" }}
#!/bin/bash
# Config hash: {{ include "macos-defaults.yaml" | sha256sum }}
defaults write com.apple.dock autohide -bool true
killall Dock
{{- end }}
```

**4. OS-Specific Scripts**

Organize in subdirectories, use template guards:

```
.chezmoiscripts/
├── darwin/
│   ├── run_once_before_install-xcode-tools.sh.tmpl
│   └── run_onchange_after_install-brew-packages.sh.tmpl
├── linux/
│   └── run_onchange_after_install-arch-packages.sh.tmpl
└── run_once_before_install-1password-cli.sh.tmpl
```

Scripts become no-ops when template evaluates to empty/whitespace.

### Script Naming Convention

```
run_[once|onchange]_[before|after]_[NN-]description.sh[.tmpl]

Examples:
run_once_before_00-install-homebrew.sh.tmpl      # Bootstrap, runs first
run_once_before_01-install-1password-cli.sh.tmpl # After Homebrew
run_onchange_after_install-packages.sh.tmpl      # On Brewfile change
run_onchange_after_reload-shell.sh.tmpl          # After shell config
```

- **Numeric prefixes (00-, 01-)** control order within category
- **Always use `.tmpl`** for conditional execution
- **Scripts must be idempotent** - safe to run multiple times

### Sourcing Utility Functions

```bash
#!/bin/bash
source "${CHEZMOI_WORKING_TREE}/scripts/utils.sh"

log_info "Installing packages..."
```

## Build Order

### Execution Sequence

Chezmoi processes in this order:

1. **Read source state** - Parse all source files
2. **Run `run_before_` scripts** - In alphabetical order
3. **Apply targets** - Files, directories, symlinks in alphabetical order
4. **Run `run_after_` scripts** - In alphabetical order

### Recommended Setup Order

For your multi-OS dotfiles, build in this order:

**Phase 1: Core Infrastructure**
1. `.chezmoi.toml.tmpl` - Device configuration prompts
2. `.chezmoidata.toml` - Static shared data
3. `.chezmoiignore` - Exclusion rules

**Phase 2: Bootstrap Scripts**
1. `run_once_before_00-install-homebrew.sh.tmpl` - Package manager
2. `run_once_before_01-install-1password-cli.sh.tmpl` - Secrets access

**Phase 3: Core Configs**
1. `dot_gitconfig.tmpl` - Git (needed for cloning)
2. `private_dot_ssh/` - SSH config
3. `dot_zshrc.tmpl` - Shell config

**Phase 4: Application Configs**
1. `dot_config/nvim/` - Editor
2. `dot_config/ghostty/` - Terminal
3. `dot_config/starship.toml` - Prompt
4. Other tool configs

**Phase 5: Package Management**
1. `Brewfile.tmpl` - macOS packages
2. `run_onchange_after_install-packages.sh.tmpl` - Package installer

**Phase 6: OS-Specific**
1. `darwin/` scripts - macOS defaults, kanata
2. `linux/` scripts - Arch packages

### Dependency Implications for Roadmap

| Setup Item | Depends On | Blocking |
|------------|------------|----------|
| 1Password CLI | Homebrew (macOS) | Secrets access |
| Git config | 1Password (for work signing key) | Nothing critical |
| SSH config | 1Password (for keys) | Git clone over SSH |
| Shell config | Package manager | Tool availability |
| Brewfile | Homebrew installed | Package installation |
| Application configs | None | Can be added anytime |

**Critical path:** Homebrew -> 1Password CLI -> Secrets available -> Everything else

**Parallelizable after secrets:** All application configs can be developed independently.

## .chezmoiignore Patterns

Template the ignore file for device-specific exclusions:

```
# .chezmoiignore

# Never manage
README.md
.git/
.planning/
scripts/

# macOS only files - ignore on Linux
{{- if ne .chezmoi.os "darwin" }}
Brewfile
.config/kanata/
Library/
{{- end }}

# Linux only files - ignore on macOS
{{- if ne .chezmoi.os "linux" }}
.config/pacman/
{{- end }}

# Work-only files - ignore on personal
{{- if not .isWork }}
.config/work-tools/
{{- end }}

# Full install only - ignore on minimal/VM
{{- if .isMinimal }}
.config/nvim/
.config/ghostty/
{{- end }}
```

## Sources

- [Chezmoi Setup Guide](https://www.chezmoi.io/user-guide/setup/)
- [Source State Attributes](https://www.chezmoi.io/reference/source-state-attributes/)
- [Templating in Chezmoi](https://www.chezmoi.io/user-guide/templating/)
- [Managing Machine Differences](https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/)
- [Use Scripts to Perform Actions](https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/)
- [Customize Your Source Directory](https://www.chezmoi.io/user-guide/advanced/customize-your-source-directory/)
- [Include Files from Elsewhere](https://www.chezmoi.io/user-guide/include-files-from-elsewhere/)
- [1Password Integration](https://www.chezmoi.io/user-guide/password-managers/1password/)
- [Chezmoi Architecture](https://www.chezmoi.io/developer-guide/architecture/)
- [Script Organization Discussion](https://github.com/twpayne/chezmoi/discussions/3506)
- [Execution Order Discussion](https://github.com/twpayne/chezmoi/discussions/1568)
