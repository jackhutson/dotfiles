# Troubleshooting

Issues encountered when applying dotfiles on different machines.

## 1Password Integration

### SSH agent socket not found

**Symptom:** Verification shows "SSH agent socket: FAIL"

**Fixes:**
1. Open 1Password Desktop app
2. Go to Settings > Developer > SSH Agent
3. Enable "Use the SSH agent"
4. Restart terminal

### SSH agent has no keys

**Symptom:** Verification shows "SSH agent keys: FAIL" or 0 keys loaded

**Fixes:**
1. Unlock 1Password
2. Go to the SSH key item in your vault
3. Enable "Use for SSH" in the key's settings
4. Run `ssh-add -l` to verify keys appear

### GitHub SSH auth fails

**Symptom:** Verification shows "GitHub SSH auth: FAIL"

**Fixes:**
1. Copy your public key: `op read "op://Personal/GitHub SSH Key/public key"`
2. Add to GitHub: https://github.com/settings/keys
3. Test: `ssh -T git@github.com`

### onepasswordRead error during chezmoi apply

**Symptom:** Error like `template: .chezmoi.toml.tmpl: error calling onepasswordRead`

**Fixes:**
1. Check 1Password CLI is installed: `op --version`
2. Sign in to 1Password CLI: `op signin`
3. Verify the item path exists:
   ```bash
   op item list --categories "SSH Key"
   ```
4. Update the `op://` path in `home/private_dot_gitconfig.tmpl` if needed

### Multiple 1Password accounts error

**Symptom:** Error like `multiple accounts found. Use the --account flag or set the OP_ACCOUNT environment variable`

**Fixes:**
1. List your accounts: `op account list`
2. Identify which account has your `Private` vault (usually personal account)
3. Set the account before running chezmoi:
   ```bash
   export OP_ACCOUNT=my.1password.com  # Replace with your account URL
   chezmoi apply
   ```
4. Or add to your chezmoi config (`~/.config/chezmoi/chezmoi.toml`):
   ```toml
   [onepassword]
       command = "op"
       args = ["--account", "my.1password.com"]
   ```

### op-ssh-sign binary not found

**Symptom:** Verification shows "op-ssh-sign binary: FAIL"

**Fixes:**
- **macOS:** Install 1Password Desktop from https://1password.com/downloads
- **Linux:** The binary is at `/opt/1Password/op-ssh-sign` after installing 1Password

### Git signing not working

**Symptom:** Commits fail with signing error, or verification shows "Git signing format: FAIL"

**Fixes:**
1. Verify config applied: `git config --global gpg.format` should show `ssh`
2. Verify signing key set: `git config --global user.signingkey` should show your public key
3. Check op-ssh-sign path matches your OS:
   - macOS: `/Applications/1Password.app/Contents/MacOS/op-ssh-sign`
   - Linux: `/opt/1Password/op-ssh-sign`

## Chezmoi Issues

### Chezmoi using wrong source directory

**Symptom:** Changes to `~/.dotfiles` not being applied, or old configs being used

**Diagnosis:**
```bash
chezmoi source-path
# Should output: /Users/yourusername/.dotfiles/home
```

**Fixes:**
1. Check for old chezmoi source at `~/.local/share/chezmoi/`:
   ```bash
   ls -la ~/.local/share/chezmoi/
   ```
2. If it exists and is outdated, back it up and remove:
   ```bash
   mv ~/.local/share/chezmoi ~/.local/share/chezmoi.bak
   ```
3. Update chezmoi config to use correct source:
   ```bash
   # Add to ~/.config/chezmoi/chezmoi.toml:
   sourceDir = "/Users/yourusername/.dotfiles"
   ```

### Config file template warning

**Symptom:** `warning: config file template has changed, run chezmoi init to regenerate config file`

**Explanation:** This warning appears when the `.chezmoi.toml.tmpl` template in the source differs from your generated `~/.config/chezmoi/chezmoi.toml`. It's usually harmless if your config is already correct.

**Fixes:**
1. If you want to regenerate config (will prompt for device type again):
   ```bash
   chezmoi init --source ~/.dotfiles
   ```
2. Or ignore the warning if your current config is correct.

### Inconsistent state with external archives

**Symptom:** Error about "inconsistent state" with oh-my-zsh or other externally managed directories

**Explanation:** Chezmoi doesn't allow both local source files and external archives for the same path.

**Fixes:**
1. Move local custom files to a different location (e.g., `~/.config/zsh/completions/`)
2. Update your shell config to include the new path in `fpath`
3. Remove the conflicting local source directory from the chezmoi source

## Platform-Specific Issues

### macOS

- 1Password agent socket: `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock`
- op-ssh-sign: `/Applications/1Password.app/Contents/MacOS/op-ssh-sign`

### Linux (including CachyOS)

- 1Password agent socket: `~/.1password/agent.sock`
- op-ssh-sign: `/opt/1Password/op-ssh-sign`
- May need to install 1Password from AUR: `yay -S 1password`

### Proxmox VMs

- 1Password Desktop may not be practical in headless VMs
- Consider using 1Password CLI only with `op read` for secrets
- SSH agent forwarding from host may be an alternative

## Verification Commands

```bash
# Quick test (uses SSH config IdentityAgent)
ssh -T git@github.com

# Check SSH agent keys (requires SSH_AUTH_SOCK to be set)
ssh-add -l
# If this returns "no identities" but GitHub works, restart your terminal
# or run: source ~/.zshrc

# Check Git signing config
git config --global --get gpg.format
git config --global --get user.signingkey
git config --global --get gpg.ssh.program

# List 1Password SSH keys
op item list --categories "SSH Key"

# Read a specific secret
op read "op://Personal/GitHub SSH Key/public key"
```

## Adding New Issues

When you encounter an issue on a new machine:
1. Document the symptom (exact error message)
2. Note the platform (macOS version, Linux distro)
3. Record the fix that worked
