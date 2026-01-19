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

## Platform-Specific Issues

### macOS

- 1Password agent socket: `~/.1password/agent.sock`
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
# Check SSH agent
ssh-add -l

# Check GitHub auth
ssh -T git@github.com

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
