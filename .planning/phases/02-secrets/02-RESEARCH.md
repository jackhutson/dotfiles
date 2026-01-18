# Phase 2: Secrets - Research

**Researched:** 2026-01-18
**Domain:** 1Password integration with Chezmoi for secrets, SSH, and Git signing
**Confidence:** HIGH

## Summary

Phase 2 integrates 1Password as the secrets provider for all templated configs. The primary mechanisms are:
1. `onepasswordRead` template function for retrieving secrets via `op://` URIs
2. 1Password SSH agent for SSH connections (no local key files)
3. 1Password `op-ssh-sign` for Git commit signing

The user has made specific decisions that constrain the implementation:
- Use 1Password's default socket location (`~/.1password/agent.sock`)
- Same SSH config on all devices (work and personal)
- No fallback to system agent - fail clearly if 1Password agent isn't running
- Sign all commits globally with same key everywhere
- Use SSH key format for signing (`gpg.format = ssh`)
- Verification via `run_after` script checking both 1Password agent AND `ssh -T git@github.com`

**Primary recommendation:** Use `onepasswordRead` with `op://vault/item/field` syntax for all secrets. Configure SSH via `~/.ssh/config` with `IdentityAgent ~/.1password/agent.sock`. Configure Git signing with `gpg.ssh.program` pointing to platform-specific `op-ssh-sign` binary.

## Standard Stack

The established tools for this phase:

### Core

| Component | Version | Purpose | Why Standard |
|-----------|---------|---------|--------------|
| **1Password CLI (op)** | 2.20.0+ | Secret retrieval | Required by chezmoi 1Password functions |
| **1Password Desktop** | Latest | SSH agent, signing | Provides SSH agent socket and op-ssh-sign |
| **chezmoi 1Password functions** | Built-in | Template integration | Native support, no extra tools needed |

### Supporting

| Component | Purpose | When to Use |
|-----------|---------|-------------|
| **op-ssh-sign** | Git commit signing | Always - bundled with 1Password Desktop |
| **~/.1password/agent.sock** | SSH agent socket | Always - consistent path across platforms |
| **~/.config/1Password/ssh/agent.toml** | Agent key selection | Optional - only if limiting which keys agent exposes |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| 1Password SSH agent | System SSH agent + keys | Requires local key files, defeats purpose of 1Password |
| op-ssh-sign | GPG signing | GPG is more complex, 1Password already manages keys |
| onepasswordRead | onepassword (JSON) | Read is simpler for single values, JSON for structured data |

**Installation:**
```bash
# 1Password CLI (macOS)
brew install 1password-cli

# 1Password CLI (Linux - Debian/Ubuntu)
curl -sS https://downloads.1password.com/linux/keys/1password.asc | sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg
echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | sudo tee /etc/apt/sources.list.d/1password.list
sudo apt update && sudo apt install 1password-cli
```

## Architecture Patterns

### Recommended Project Structure

```
home/
├── .chezmoi.toml.tmpl           # 1Password config (mode, prompt)
├── .chezmoiscripts/
│   └── run_after_verify-secrets.sh.tmpl  # Verification script
├── private_dot_ssh/
│   └── config.tmpl              # SSH config with IdentityAgent
├── private_dot_gitconfig.tmpl   # Git config with signing
└── dot_config/
    └── private_1Password/
        └── ssh/
            └── agent.toml       # Optional: agent key selection
```

**Key naming conventions:**
- `private_` prefix: File permissions set to 0600, excluded from diff by default
- `.tmpl` suffix: Processed as Go template, can use `onepasswordRead`

### Pattern 1: Secret Retrieval with onepasswordRead

**What:** Use `onepasswordRead` with `op://` URIs to fetch secrets at apply time.
**When to use:** Any templated config that needs a secret value.

```go-template
{{/* Syntax: onepasswordRead "op://vault/item/field" ["account"] */}}

{{/* Simple secret retrieval */}}
export API_KEY="{{ onepasswordRead "op://Personal/api-token/credential" }}"

{{/* SSH public key for Git signing */}}
signingkey = {{ onepasswordRead "op://Personal/GitHub SSH Key/public key" | quote }}
```

**Source:** [onepasswordRead reference](https://www.chezmoi.io/reference/templates/1password-functions/onepasswordRead/)

### Pattern 2: SSH Config with 1Password Agent

**What:** Configure SSH to use 1Password's SSH agent instead of system agent.
**When to use:** All SSH connections should use 1Password-managed keys.

```go-template
{{/* private_dot_ssh/config.tmpl */}}

# Use 1Password SSH agent for all hosts
Host *
    IdentityAgent "~/.1password/agent.sock"

# GitHub-specific config
Host github.com
    HostName github.com
    User git
    IdentityAgent "~/.1password/agent.sock"
```

**Key insight:** The socket path `~/.1password/agent.sock` works on both macOS and Linux. On macOS, 1Password creates this symlink automatically. On Linux, this is the native path.

**Source:** [1Password SSH agent setup](https://developer.1password.com/docs/ssh/get-started/)

### Pattern 3: Git Signing with Platform-Specific Binary

**What:** Configure Git to sign commits using 1Password's `op-ssh-sign` binary.
**When to use:** All Git commits should be signed.

```go-template
{{/* private_dot_gitconfig.tmpl */}}

[user]
    name = {{ .git.name | quote }}
    email = {{ .email | quote }}
    {{/* Public key for signing - retrieved from 1Password */}}
    signingkey = {{ onepasswordRead "op://Personal/GitHub SSH Key/public key" | quote }}

[commit]
    gpgsign = true

[gpg]
    format = ssh

[gpg "ssh"]
    {{/* Platform-specific path to op-ssh-sign */}}
    {{ if eq .chezmoi.os "darwin" -}}
    program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    {{ else -}}
    program = "/opt/1Password/op-ssh-sign"
    {{ end -}}
```

**Source:** [1Password Git commit signing](https://developer.1password.com/docs/ssh/git-commit-signing/)

### Pattern 4: Verification Script

**What:** A `run_after` script that verifies SSH and signing are working.
**When to use:** Run after every `chezmoi apply` to catch configuration issues early.

```bash
{{/* .chezmoiscripts/run_after_verify-secrets.sh.tmpl */}}
#!/bin/bash
set -e

echo "Verifying 1Password integration..."

# Check 1: 1Password SSH agent socket exists
if [ ! -S "$HOME/.1password/agent.sock" ]; then
    echo "ERROR: 1Password SSH agent socket not found at ~/.1password/agent.sock"
    echo "Please enable SSH agent in 1Password settings"
    exit 1
fi

# Check 2: SSH agent is responding
if ! SSH_AUTH_SOCK="$HOME/.1password/agent.sock" ssh-add -l >/dev/null 2>&1; then
    echo "ERROR: 1Password SSH agent not responding"
    echo "Please unlock 1Password and ensure SSH agent is enabled"
    exit 1
fi

# Check 3: GitHub SSH authentication works
if ! ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "ERROR: GitHub SSH authentication failed"
    echo "Please add your SSH key to GitHub and approve in 1Password"
    exit 1
fi

# Check 4: Git signing is configured
if [ "$(git config --global gpg.format)" != "ssh" ]; then
    echo "ERROR: Git signing not configured"
    exit 1
fi

echo "All 1Password integration checks passed!"
```

**Source:** User decision from CONTEXT.md

### Anti-Patterns to Avoid

- **Storing SSH keys in dotfiles:** Use 1Password SSH agent, never commit private keys
- **Using system SSH agent as fallback:** Breaks clear failure mode - if 1Password isn't running, fail explicitly
- **Different signing keys per device:** User decision to use same key everywhere
- **Using GPG format for signing:** Use SSH format (`gpg.format = ssh`) with 1Password
- **Hardcoding secrets in templates:** Always use `onepasswordRead`

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Secret retrieval | Shelling out to `op read` | `onepasswordRead` function | Built-in caching, session handling |
| SSH agent forwarding | Custom socket paths | `~/.1password/agent.sock` | Consistent across platforms |
| Signing binary path | Manual PATH lookup | Platform conditionals | Known fixed paths per platform |
| Session management | Manual `op signin` | `onepassword.prompt = true` | Chezmoi handles interactively |
| Key selection | Manual IdentityFile | 1Password SSH agent | Agent handles key selection |

**Key insight:** 1Password has already solved the hard problems (agent socket management, signing integration, session handling). Don't reimplement what's built-in.

## Common Pitfalls

### Pitfall 1: Socket Path Varies by Platform

**What goes wrong:** Using macOS socket path on Linux or vice versa fails silently.

**Why it happens:** macOS native path is `~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock`, Linux is `~/.1password/agent.sock`.

**How to avoid:** Use `~/.1password/agent.sock` which works on both:
- Linux: Native path
- macOS: 1Password creates a symlink automatically (or you can create it manually)

**Warning signs:** SSH connections fail with "no identity found" or "permission denied".

**Verification:** `SSH_AUTH_SOCK=~/.1password/agent.sock ssh-add -l` should list keys.

### Pitfall 2: op-ssh-sign Binary Path is Platform-Specific

**What goes wrong:** Git signing fails because `gpg.ssh.program` path doesn't exist.

**Why it happens:** Binary location differs:
- macOS: `/Applications/1Password.app/Contents/MacOS/op-ssh-sign`
- Linux: `/opt/1Password/op-ssh-sign`

**How to avoid:** Use platform conditional in template:
```go-template
{{ if eq .chezmoi.os "darwin" -}}
program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
{{ else -}}
program = "/opt/1Password/op-ssh-sign"
{{ end -}}
```

**Warning signs:** `error: cannot run /path/to/op-ssh-sign: No such file or directory`

### Pitfall 3: 1Password CLI Not Signed In

**What goes wrong:** `chezmoi apply` hangs or fails waiting for 1Password authentication.

**Why it happens:** `onepasswordRead` requires an active 1Password session.

**How to avoid:** Either:
1. Set `onepassword.prompt = true` (default) - will prompt interactively
2. Sign in via `op signin` before running chezmoi
3. Use biometric unlock in 1Password Desktop

**Warning signs:** Long pauses during `chezmoi apply`, "not signed in" errors.

**Verification:** `op whoami` should return account info.

### Pitfall 4: SSH Key Not in 1Password SSH Agent Scope

**What goes wrong:** SSH connection fails even though key exists in 1Password.

**Why it happens:** By default, only keys in Personal/Private/Employee vaults are available to SSH agent.

**How to avoid:** Either:
1. Keep SSH keys in default vaults
2. Create `~/.config/1Password/ssh/agent.toml` to specify which vaults/keys to use

**Warning signs:** `ssh-add -l` shows no keys, but key exists in 1Password vault.

### Pitfall 5: Git Signing Key Doesn't Match Email

**What goes wrong:** Commits are signed but show as "Unverified" on GitHub.

**Why it happens:** GitHub requires the signing key's email to match the commit author email.

**How to avoid:** Ensure the SSH key in 1Password has the same email as `user.email` in Git config.

**Warning signs:** Commits show "Unverified" on GitHub despite being signed.

**Verification:** Check key email with `op item get "GitHub SSH Key" --fields label=email`

### Pitfall 6: chezmoi diff Shows Secrets in Plain Text

**What goes wrong:** Running `chezmoi diff` reveals actual secret values in terminal output.

**Why it happens:** chezmoi evaluates templates before diffing, so secrets are fetched and displayed.

**How to avoid:** This is expected behavior - secrets must be fetched to compare. Options:
1. Use `private_` prefix on files with secrets (not shown in diff by default)
2. Pipe diff output carefully (don't log to files)
3. Trust that diffs are local-only terminal output

**User decision:** Per CONTEXT.md, placeholder approach is desired. However, chezmoi doesn't natively support this. The `private_` prefix is the closest built-in solution.

**Warning signs:** Secrets visible in `chezmoi diff` output.

## Code Examples

Verified patterns from official sources:

### Complete .chezmoi.toml.tmpl Addition for 1Password

```go-template
{{/* Add to existing .chezmoi.toml.tmpl */}}

[onepassword]
    prompt = true
```

**Source:** [1Password configuration](https://www.chezmoi.io/user-guide/password-managers/1password/)

### Complete SSH Config Template

```go-template
{{/* private_dot_ssh/config.tmpl */}}

# 1Password SSH Agent Configuration
# No fallback to system agent - fail explicitly if 1Password isn't running

Host *
    # Use 1Password SSH agent for all connections
    IdentityAgent "~/.1password/agent.sock"
    # Don't try default identity files
    IdentitiesOnly yes
    # Add keys to agent automatically
    AddKeysToAgent yes

# GitHub
Host github.com
    HostName github.com
    User git

# GitLab (if needed later)
# Host gitlab.com
#     HostName gitlab.com
#     User git
```

**Source:** [1Password SSH configuration](https://developer.1password.com/docs/ssh/get-started/)

### Complete Git Config Template

```go-template
{{/* private_dot_gitconfig.tmpl */}}

[user]
    name = {{ .git.name | quote }}
    email = {{ .email | quote }}
    signingkey = {{ onepasswordRead "op://Personal/GitHub SSH Key/public key" | quote }}

[init]
    defaultBranch = {{ .git.defaultBranch | quote }}

[commit]
    gpgsign = true

[tag]
    gpgsign = true

[gpg]
    format = ssh

[gpg "ssh"]
{{ if eq .chezmoi.os "darwin" -}}
    program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
{{ else -}}
    program = "/opt/1Password/op-ssh-sign"
{{ end -}}

[core]
    editor = {{ .editor.default | quote }}

[pull]
    rebase = false

[push]
    autoSetupRemote = true
```

**Source:** [1Password Git signing](https://developer.1password.com/docs/ssh/git-commit-signing/), [chezmoi onepasswordRead](https://www.chezmoi.io/reference/templates/1password-functions/onepasswordRead/)

### Verification Script

```bash
{{/* .chezmoiscripts/run_after_10-verify-secrets.sh.tmpl */}}
#!/bin/bash

# Verification script for 1Password integration
# Runs after chezmoi apply to ensure configuration is working

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

errors=0

echo "Verifying 1Password integration..."

# Check 1: SSH agent socket exists
echo -n "  SSH agent socket... "
if [ -S "$HOME/.1password/agent.sock" ]; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    echo "    Socket not found at ~/.1password/agent.sock"
    echo "    Enable SSH agent: 1Password > Settings > Developer > SSH Agent"
    ((errors++))
fi

# Check 2: SSH agent has keys
echo -n "  SSH agent keys... "
if SSH_AUTH_SOCK="$HOME/.1password/agent.sock" ssh-add -l >/dev/null 2>&1; then
    key_count=$(SSH_AUTH_SOCK="$HOME/.1password/agent.sock" ssh-add -l | wc -l)
    echo -e "${GREEN}OK${NC} ($key_count keys)"
else
    echo -e "${RED}FAILED${NC}"
    echo "    No keys available from SSH agent"
    echo "    Unlock 1Password and ensure SSH keys have 'Use for SSH' enabled"
    ((errors++))
fi

# Check 3: GitHub SSH authentication
echo -n "  GitHub SSH auth... "
github_result=$(ssh -T git@github.com 2>&1)
if echo "$github_result" | grep -q "successfully authenticated"; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    echo "    GitHub SSH authentication failed"
    echo "    Add your public key to GitHub: https://github.com/settings/keys"
    ((errors++))
fi

# Check 4: Git signing configuration
echo -n "  Git signing config... "
gpg_format=$(git config --global gpg.format 2>/dev/null)
if [ "$gpg_format" = "ssh" ]; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    echo "    gpg.format should be 'ssh', got '$gpg_format'"
    ((errors++))
fi

# Check 5: op-ssh-sign binary exists
echo -n "  op-ssh-sign binary... "
{{ if eq .chezmoi.os "darwin" -}}
op_ssh_sign="/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
{{ else -}}
op_ssh_sign="/opt/1Password/op-ssh-sign"
{{ end -}}
if [ -x "$op_ssh_sign" ]; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    echo "    Binary not found at $op_ssh_sign"
    echo "    Install 1Password Desktop app"
    ((errors++))
fi

echo ""
if [ $errors -eq 0 ]; then
    echo -e "${GREEN}All 1Password integration checks passed!${NC}"
    exit 0
else
    echo -e "${RED}$errors check(s) failed${NC}"
    echo "Please fix the issues above and run 'chezmoi apply' again"
    exit 1
fi
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| GPG for signing | SSH keys with op-ssh-sign | 1Password 8 (2022) | Simpler, unified key management |
| Local SSH keys | 1Password SSH agent | 1Password 8 (2022) | Keys never leave 1Password |
| `onepassword` JSON parsing | `onepasswordRead` for single values | chezmoi 2.x | Simpler syntax for common case |
| Manual socket paths | `~/.1password/agent.sock` symlink | 1Password 8.7+ | Consistent cross-platform |

**Deprecated/outdated:**
- Using `gpg.format = gpg` with 1Password - use `gpg.format = ssh` instead
- `IdentityFile` in SSH config for 1Password keys - use `IdentityAgent` instead
- Manual `op signin` before chezmoi - use `onepassword.prompt = true`

## Open Questions

Things that couldn't be fully resolved:

1. **Placeholder text in chezmoi diff**
   - What we know: chezmoi doesn't have built-in support for masking secrets in diff output
   - What's unclear: Whether `private_` prefix fully hides from diff, or just changes permissions
   - Recommendation: Use `private_` prefix, accept that secrets appear in diff (local terminal only)

2. **1Password account specification in multi-account scenarios**
   - What we know: `onepasswordRead` accepts optional account parameter
   - What's unclear: Whether user has multiple 1Password accounts requiring disambiguation
   - Recommendation: Start without account param, add if needed

3. **SSH key vault organization**
   - What we know: User may have keys in Personal or Private vault
   - What's unclear: Exact vault and item names to use in `op://` URIs
   - Recommendation: Use `op item list --categories "SSH Key"` to discover, then document

## Sources

### Primary (HIGH confidence)
- [chezmoi 1Password documentation](https://www.chezmoi.io/user-guide/password-managers/1password/) - Integration setup
- [onepasswordRead reference](https://www.chezmoi.io/reference/templates/1password-functions/onepasswordRead/) - Template function syntax
- [1Password SSH agent](https://developer.1password.com/docs/ssh/agent/) - Agent setup
- [1Password Git commit signing](https://developer.1password.com/docs/ssh/git-commit-signing/) - Signing configuration
- [1Password secret reference syntax](https://developer.1password.com/docs/cli/secret-reference-syntax/) - op:// URI format

### Secondary (MEDIUM confidence)
- [abrauner/dotfiles](https://github.com/abrauner/dotfiles) - Real-world chezmoi + 1Password example
- [Dev env setup with chezmoi](https://danielmschmidt.de/posts/2024-07-28-dev-env-setup-with-chezmoi/) - Practical Git signing example
- [Ken Muse: Automatic SSH Commit Signing](https://www.kenmuse.com/blog/automatic-ssh-commit-signing-with-1password/) - Platform-specific paths

### Tertiary (LOW confidence)
- Community discussions about diff masking - no official support found

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Official 1Password and chezmoi documentation
- Architecture: HIGH - Patterns verified in official docs and real repos
- Pitfalls: HIGH - Documented gotchas from official troubleshooting guides
- Diff masking: LOW - No official support found, user may need to accept limitation

**Research date:** 2026-01-18
**Valid until:** 2026-02-18 (30 days - 1Password and chezmoi are stable)
