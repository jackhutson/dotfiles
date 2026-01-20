# Dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io).

## Features

- **Multi-device support**: Conditional configs for work/personal macOS and Linux
- **1Password integration**: SSH agent, git commit signing, secrets management
- **Modern shell**: zsh + oh-my-zsh + starship prompt (Catppuccin theme)
- **Developer tools**: neovim, lazygit, fzf, ripgrep, bat, eza, and more
- **Keyboard remapping**: kanata for home row mods (macOS only)

## Quick Start

### Fresh Machine (Recommended)

```bash
# Prerequisites: git, curl, 1Password CLI (op)
curl -fsSL https://raw.githubusercontent.com/jackhutson/dotfiles/master/bootstrap.sh | sh
```

### Existing Machine

```bash
# Clone the repo
git clone https://github.com/jackhutson/dotfiles.git ~/.dotfiles

# Install chezmoi if not present
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

# Initialize chezmoi with this repo
chezmoi init --source ~/.dotfiles --apply
```

## Prerequisites

| Tool | Purpose | Install |
|------|---------|---------|
| git | Version control | Pre-installed on macOS |
| curl | Downloads | Pre-installed on macOS |
| 1Password CLI | Secrets management | `brew install 1password-cli` |
| 1Password Desktop | SSH agent, signing | [1password.com/downloads](https://1password.com/downloads) |

## Post-Install

1. **1Password Setup**:
   - Enable SSH Agent: Settings > Developer > SSH Agent
   - Enable CLI integration: Settings > Developer > Connect with 1Password CLI

2. **Verify installation**:
   ```bash
   ssh-add -l              # Should list SSH keys
   ssh -T git@github.com   # Should authenticate
   ```

3. **Apply changes**:
   ```bash
   chezmoi apply
   ```

## Usage

```bash
# See what would change
chezmoi diff

# Apply changes
chezmoi apply

# Edit a managed file
chezmoi edit ~/.zshrc

# Add a new file to management
chezmoi add ~/.some-config
```

## Multi-Account 1Password

If you have multiple 1Password accounts, set the account before running chezmoi:

```bash
export OP_ACCOUNT=my.1password.com  # Your personal account with Private vault
chezmoi apply
```

Or add to `~/.config/chezmoi/chezmoi.toml`:

```toml
[onepassword]
    command = "op"
    args = ["--account", "my.1password.com"]
```

## Structure

```
~/.dotfiles/
├── bootstrap.sh           # Fresh machine installer
├── home/                   # Chezmoi source directory
│   ├── .chezmoi.toml.tmpl # Device configuration template
│   ├── .chezmoiexternal.toml # External dependencies (oh-my-zsh, plugins)
│   ├── .chezmoiignore     # Files to ignore per OS/device type
│   ├── dot_config/        # ~/.config files
│   ├── dot_zshrc.tmpl     # Shell configuration
│   └── private_dot_*      # Private files (gitconfig, ssh)
├── docs/                   # Documentation
│   └── TROUBLESHOOTING.md # Common issues and fixes
└── .planning/              # Project planning (GSD)
```

## Troubleshooting

See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for common issues.

## Device Matrix

| Device | OS | Setup Level |
|--------|-----|------------|
| Work MacBook | macOS | Full |
| Personal MacBook | macOS | Full |
| M7 (CachyOS) | Linux/Arch | Full |
| Proxmox VMs | Linux | Minimal |
