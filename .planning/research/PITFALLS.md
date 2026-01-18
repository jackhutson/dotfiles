# Pitfalls Research: Chezmoi Dotfiles Management

**Domain:** Cross-platform dotfiles management with Chezmoi
**Researched:** 2026-01-18
**Confidence:** HIGH (verified against official Chezmoi documentation)

---

## Critical Pitfalls

Mistakes that cause data loss, security breaches, or require complete rework.

### 1. Accidentally Pushing Secrets to Public Repository

**What goes wrong:** Secrets (API keys, tokens, SSH private keys) end up in git history when using autoCommit/autoPush features, or when adding files as templates without sanitizing first.

**Why it happens:**
- `chezmoi add --template` copies the file as-is by default
- autoCommit triggers before you have time to edit the template
- No automatic secret detection without explicit configuration

**Consequences:**
- Credentials exposed in public repository
- Git history requires rewriting (difficult)
- Potential account compromise

**Warning signs:**
- Using autoPush without add.secrets configured
- Adding existing config files without reviewing contents first
- No password manager integration set up

**Prevention:**
1. Configure `add.secrets = "error"` in chezmoi config to block unencrypted secrets
2. Use only `autoCommit` (not `autoPush`) while learning - gives you a chance to review before push
3. Set up 1Password integration FIRST before adding any sensitive files
4. Always run `chezmoi diff` before `chezmoi apply` to review changes

**Phase to address:** Phase 1 (Initial Setup) - configure add.secrets and 1Password integration before adding any files

**Sources:**
- [Chezmoi Daily Operations](https://www.chezmoi.io/user-guide/daily-operations/)
- [GitHub Issue #3745 - autoCommit/autoPush templating](https://github.com/twpayne/chezmoi/issues/3745)

---

### 2. Editing Target Files Instead of Source Files

**What goes wrong:** You edit `~/.zshrc` directly instead of using `chezmoi edit ~/.zshrc`, then run `chezmoi apply` which overwrites your changes.

**Why it happens:**
- Muscle memory from pre-chezmoi days
- Not understanding the source/target relationship
- Forgetting chezmoi is managing the file

**Consequences:**
- Lost configuration changes
- Hours of work destroyed with one command
- Frustration and distrust of the tool

**Warning signs:**
- Using `vim ~/.config/file` instead of `chezmoi edit`
- Seeing "file has changed since chezmoi last wrote it" prompts
- `chezmoi diff` shows unexpected differences

**Prevention:**
1. Create shell aliases: `alias ce='chezmoi edit'`, `alias ca='chezmoi apply'`
2. Always run `chezmoi diff` before `chezmoi apply`
3. Set up editor with `--wait` flag (VSCode) or `-f` flag (Vim) to keep editor in foreground
4. Use `chezmoi edit --watch` to auto-apply on save

**Phase to address:** Phase 1 (Initial Setup) - create aliases and configure editor properly

**Sources:**
- [Chezmoi Usage FAQ](https://www.chezmoi.io/user-guide/frequently-asked-questions/usage/)
- [Chezmoi Troubleshooting](https://www.chezmoi.io/user-guide/frequently-asked-questions/troubleshooting/)

---

### 3. 1Password Session Token Exposed on Shared Machines

**What goes wrong:** Using `onepassword.prompt = false` passes session tokens via command-line parameters, visible to other users on the same system.

**Why it happens:**
- Trying to make 1Password integration "more convenient"
- Not understanding security implications of prompt modes
- Copy-pasting config without understanding

**Consequences:**
- Other users on the machine can see your 1Password session token
- Potential access to all secrets in your vault

**Warning signs:**
- Using chezmoi on shared servers or CI systems
- Disabling prompt mode in config
- Running chezmoi where others can run `ps aux`

**Prevention:**
1. Never disable prompts on shared machines
2. Use Service Account mode for CI/automation (isolated tokens)
3. For personal machines with biometric auth, prompts are already bypassed safely

**Phase to address:** Phase 2 (1Password Integration) - understand mode implications before configuring

**Sources:**
- [Chezmoi 1Password Documentation](https://www.chezmoi.io/user-guide/password-managers/1password/)

---

### 4. `chezmoi init` Destroys Existing Source Directory Symlink

**What goes wrong:** If you symlink `~/.local/share/chezmoi` to a cloud-synced location, `chezmoi init` will remove the symlink and create a regular directory.

**Why it happens:**
- Trying to sync source directory via Dropbox/iCloud
- Not using chezmoi's built-in git integration
- Misunderstanding how init works

**Consequences:**
- Symlink replaced with empty directory
- Connection to cloud sync broken
- Potential loss of source state if not backed up

**Prevention:**
1. Use `sourceDir` config to point to alternate location instead of symlinks
2. Use git + GitHub for syncing (chezmoi's intended workflow)
3. If you must use cloud sync, configure `sourceDir` in chezmoi config

**Phase to address:** Phase 1 (Initial Setup) - decide on sync strategy before any init

**Sources:**
- [Chezmoi Design FAQ](https://www.chezmoi.io/user-guide/frequently-asked-questions/design/)
- [GitHub Discussion #4311](https://github.com/twpayne/chezmoi/discussions/4311)

---

## Common Mistakes

Frequent errors that cause delays, confusion, or technical debt.

### 5. Inverted Logic in .chezmoiignore

**What goes wrong:** Writing `{{ if eq .chezmoi.os "darwin" }}` to include macOS files, when you should use `{{ if ne .chezmoi.os "darwin" }}` to ignore on non-macOS.

**Why it happens:**
- Chezmoi includes everything by default
- .chezmoiignore specifies what to EXCLUDE, not include
- Mental model conflict with typical config file patterns

**Warning signs:**
- Files appearing on wrong platform
- Files missing on expected platform
- Template conditionals seem backwards

**Prevention:**
1. Remember: .chezmoiignore lists what to IGNORE, so use `ne` (not equal) for platform-specific files
2. Test with `chezmoi ignored` to see actual ignored files
3. Comment your ignore patterns explaining the logic

**Example (correct):**
```
# Ignore macOS-specific files on non-macOS systems
{{ if ne .chezmoi.os "darwin" }}
Library/**
.config/karabiner/**
{{ end }}

# Ignore Linux-specific files on non-Linux systems
{{ if ne .chezmoi.os "linux" }}
.config/systemd/**
{{ end }}
```

**Phase to address:** Phase 3 (Cross-Platform Templating) - understand ignore semantics before creating platform-specific files

**Sources:**
- [Chezmoi Manage Machine Differences](https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/)

---

### 6. run_once Scripts Won't Re-run After Reverting Changes

**What goes wrong:** You modify a `run_once_` script, it runs. You revert the change, it won't run again because the original hash is still in the database.

**Why it happens:**
- chezmoi tracks SHA256 hashes of script content, not filenames
- Once a hash has executed, it's recorded permanently
- Reverting to old content = old hash = won't execute

**Warning signs:**
- Script "should" run but doesn't
- Script worked, you changed it, then changed back, now it won't run
- Renaming script doesn't help

**Prevention:**
1. Prefer `run_onchange_` scripts for most cases (they re-run when content changes)
2. Use `run_once_` only for true one-time operations (initial setup)
3. If you need to re-run: `chezmoi state delete-bucket --bucket=scriptState`
4. For debugging: add a comment with a version number to change the hash

**Phase to address:** Phase 4 (Bootstrap Scripts) - understand script execution model before writing scripts

**Sources:**
- [Chezmoi Scripts Documentation](https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/)
- [GitHub Discussion #1678 - run_once cache](https://github.com/twpayne/chezmoi/discussions/1678)

---

### 7. `chezmoi add` Fails in External Archive Directories

**What goes wrong:** You use externals to manage Oh My Zsh, then try to `chezmoi add` a custom plugin file inside that directory. Chezmoi fails with confusing errors.

**Why it happens:**
- chezmoi add doesn't understand the external/overlay hierarchy
- Externals own their directories completely
- chezmoi tries to create impossible paths

**Warning signs:**
- Using externals for frameworks (Oh My Zsh, Prezto, etc.)
- Wanting to add custom files inside external directories
- Error messages about broken paths

**Prevention:**
1. For files that overlay externals, manually copy to source directory
2. Plan your external boundaries carefully
3. Consider whether external is the right choice vs. managing directly

**Phase to address:** Phase 3 (Externals/Plugins) - understand external limitations before adoption

**Sources:**
- [Chezmoi Externals Documentation](https://www.chezmoi.io/user-guide/include-files-from-elsewhere/)
- [Why chezmoi add Fails with Externals](https://mischavandenburg.com/zet/chezmoi-add-fails-with-externals/)

---

### 8. External Archive Causes Constant "Changes Detected"

**What goes wrong:** You add Oh My Zsh as an external, but every `chezmoi apply` shows changes because OMZ creates cache files.

**Why it happens:**
- chezmoi validates exact contents of external directories
- Applications create runtime cache/state files
- These files don't exist in the archive, so chezmoi sees "changes"

**Warning signs:**
- `chezmoi diff` always shows differences in external directories
- Cache directories appearing in diff output
- Frustrating false positives during apply

**Prevention:**
1. Add cache directories to .chezmoiignore:
   ```
   .oh-my-zsh/cache/**
   .oh-my-zsh/.git/**
   ```
2. Disable auto-update in Oh My Zsh: `DISABLE_AUTO_UPDATE="true"`
3. For large/dynamic externals, consider `run_onchange_` script instead

**Phase to address:** Phase 3 (Externals/Plugins) - add ignore patterns immediately when adding externals

**Sources:**
- [Chezmoi Include Files from Elsewhere](https://www.chezmoi.io/user-guide/include-files-from-elsewhere/)

---

### 9. Script Newline Before Shebang

**What goes wrong:** Template script has `{{ if condition }}` on line 1, then `#!/bin/bash` on line 2. After template execution, there's a newline before the shebang, causing "exec format error".

**Why it happens:**
- Template syntax takes up space
- Newline after `}}` preserved in output
- Shell requires `#!` to be absolute first characters

**Warning signs:**
- Scripts work locally but fail on some machines
- "exec format error" or "format error" messages
- Script file has correct shebang but won't execute

**Prevention:**
Use whitespace-trimming syntax: `{{- if condition -}}` (note the dashes)

**Example (correct):**
```bash
{{- if eq .chezmoi.os "darwin" -}}
#!/bin/bash
# macOS-specific script
{{- end -}}
```

**Phase to address:** Phase 4 (Bootstrap Scripts) - use correct template syntax from the start

**Sources:**
- [Chezmoi Troubleshooting](https://www.chezmoi.io/user-guide/frequently-asked-questions/troubleshooting/)

---

### 10. 1Password Multiple Account Limitation

**What goes wrong:** You try to use both personal and work 1Password accounts with Service Account or Connect modes, but chezmoi can only access one.

**Why it happens:**
- Service Account and Connect modes are single-account only
- Environment variables can only hold one account's credentials
- chezmoi requires explicit mode configuration

**Warning signs:**
- Need secrets from multiple 1Password accounts
- Using Service Account mode for CI/automation
- Seeing "account" errors when switching contexts

**Prevention:**
1. For multiple accounts, use standard "account" mode (not Service/Connect)
2. Structure secrets in a single account if possible
3. For CI, consider if you really need multiple accounts

**Phase to address:** Phase 2 (1Password Integration) - audit account requirements before choosing mode

**Sources:**
- [Chezmoi 1Password Documentation](https://www.chezmoi.io/user-guide/password-managers/1password/)

---

## Subtle Issues

Things that seem fine initially but cause problems over time.

### 11. Template Missingkey Causes Silent Failures

**What goes wrong:** You typo a variable name like `.chezmoi.hostnme` (missing 'a'), and chezmoi errors out on all templates, not just the one with the typo.

**Why it happens:**
- chezmoi uses `missingkey=error` by default (good for catching typos)
- One bad template can break all template processing
- Error messages may not clearly identify which file has the issue

**Warning signs:**
- Templates suddenly stop working after adding new file
- Error messages about missing keys
- Can't identify which file has the problem

**Prevention:**
1. Test new templates with `chezmoi execute-template`
2. Add templates incrementally, testing after each
3. Use `chezmoi doctor` to identify problems
4. Read error messages carefully - they usually include the key name

**Phase to address:** Throughout all phases - test templates before committing

**Sources:**
- [Chezmoi Templates Reference](https://www.chezmoi.io/reference/templates/)

---

### 12. .tmpl Suffix Breaks Editor Syntax Highlighting

**What goes wrong:** You rename `.zshrc` to `.zshrc.tmpl` for templating, but now your editor shows no syntax highlighting because it doesn't recognize the file type.

**Why it happens:**
- Editors use file extensions for language detection
- `.tmpl` is not a recognized shell script extension
- chezmoi's naming convention conflicts with editor conventions

**Warning signs:**
- No syntax highlighting in templated files
- Editor treating file as plain text
- Losing productivity due to poor editor experience

**Prevention:**
1. Configure editor to associate `.tmpl` files with their base language
2. For many configs (bash, TOML), you can embed template syntax in comments/strings without needing .tmpl suffix
3. Use `.chezmoitemplates` directory for pure template files

**Editor config example (VSCode settings.json):**
```json
{
  "files.associations": {
    "*.zshrc.tmpl": "shellscript",
    "*.bashrc.tmpl": "shellscript",
    "*.toml.tmpl": "toml"
  }
}
```

**Phase to address:** Phase 1 (Initial Setup) - configure editor associations before heavy templating

**Sources:**
- [PBS 123 - Chezmoi Templating](https://pbs.bartificer.net/pbs123)

---

### 13. .chezmoidata Does NOT Support Templates

**What goes wrong:** You try to use template syntax in `.chezmoidata/data.yaml` to compute values dynamically, but it's treated as literal text.

**Why it happens:**
- Race condition: data files provide values FOR templates
- Templates can't process data files that provide their input
- Only `chezmoi.toml.tmpl` (during init) supports templating

**Warning signs:**
- Template syntax appearing literally in output
- Expecting dynamic data computation
- Confusion about why templates don't work

**Prevention:**
1. Use `chezmoi.toml.tmpl` for init-time computed values (runs once during `chezmoi init`)
2. Use scripts to generate dynamic data if needed
3. Accept that data files are static definitions

**Phase to address:** Phase 3 (Cross-Platform Templating) - understand data vs template distinction

**Sources:**
- [GitHub Discussion #4220 - Template interpretation in .chezmoidata](https://github.com/twpayne/chezmoi/discussions/4220)

---

### 14. Concurrent chezmoi Instances Cause Lock Timeout

**What goes wrong:** You run a `run_` script that invokes `chezmoi`, but the parent chezmoi already holds the lock, causing timeout or deadlock.

**Why it happens:**
- chezmoi uses a database lock for state consistency
- Nested chezmoi invocations compete for the same lock
- Scripts may inadvertently call chezmoi

**Warning signs:**
- "timeout obtaining persistent state lock" errors
- Scripts that work standalone but fail during apply
- Mysterious timeouts during chezmoi operations

**Prevention:**
1. Never invoke chezmoi from within chezmoi scripts
2. If you need chezmoi data in a script, use template variables instead
3. Check `chezmoi doctor` for lock-related issues

**Phase to address:** Phase 4 (Bootstrap Scripts) - design scripts to be self-contained

**Sources:**
- [Chezmoi Troubleshooting](https://www.chezmoi.io/user-guide/frequently-asked-questions/troubleshooting/)

---

### 15. Empty Template Creates File Deletion

**What goes wrong:** Your conditional template evaluates to empty on certain machines, and chezmoi removes the existing target file.

**Why it happens:**
- chezmoi treats empty template output as "this file should not exist"
- Conditional logic may unintentionally produce empty output
- Differs from expected "leave file alone" behavior

**Warning signs:**
- Files disappearing on certain machines
- Templates with complex conditionals
- `chezmoi diff` shows file deletions you didn't expect

**Prevention:**
1. If you need an intentionally empty file, use `empty_` prefix
2. For conditionals, consider using .chezmoiignore instead of empty templates
3. Test templates with `chezmoi execute-template` on edge cases

**Phase to address:** Phase 3 (Cross-Platform Templating) - test template edge cases

**Sources:**
- [Chezmoi Manage Machine Differences](https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/)

---

### 16. Large Externals Slow Down Every Diff/Apply

**What goes wrong:** You add a large framework or archive as an external, and now `chezmoi diff` takes 30+ seconds because it validates all external contents.

**Why it happens:**
- chezmoi validates exact contents of externals on every diff/apply/verify
- Large archives = lots of files to check
- No incremental or cached validation

**Warning signs:**
- Slow chezmoi operations after adding externals
- Large frameworks managed as externals (Spacemacs, Doom Emacs, etc.)
- Noticeable delay before diff output appears

**Prevention:**
1. Don't use externals for large archives
2. Use `run_onchange_` scripts for large frameworks (checks hash, unpacks once)
3. Keep externals small (individual plugins, not entire frameworks)

**Phase to address:** Phase 3 (Externals/Plugins) - evaluate size before using external

**Sources:**
- [Chezmoi Include Files from Elsewhere](https://www.chezmoi.io/user-guide/include-files-from-elsewhere/)

---

## Prevention Strategies Summary

### Phase 1: Initial Setup
| Pitfall | Prevention |
|---------|------------|
| Secrets leak (#1) | Configure `add.secrets = "error"`, set up 1Password first |
| Edit wrong file (#2) | Create aliases, configure editor with --wait |
| Symlink destroyed (#4) | Use `sourceDir` config, not symlinks |
| Editor highlighting (#12) | Configure file associations |

### Phase 2: 1Password Integration
| Pitfall | Prevention |
|---------|------------|
| Session token exposure (#3) | Never disable prompts on shared machines |
| Multi-account limitation (#10) | Audit account requirements, use "account" mode |

### Phase 3: Cross-Platform Templating
| Pitfall | Prevention |
|---------|------------|
| Inverted ignore logic (#5) | Use `ne` for platform-specific ignores |
| External add failures (#7) | Manually copy overlay files |
| External cache drift (#8) | Add cache paths to .chezmoiignore |
| .chezmoidata templates (#13) | Use chezmoi.toml.tmpl for dynamic init data |
| Empty template deletion (#15) | Use empty_ prefix or .chezmoiignore |
| Large external slowdown (#16) | Use run_onchange_ for large frameworks |

### Phase 4: Bootstrap Scripts
| Pitfall | Prevention |
|---------|------------|
| run_once hash tracking (#6) | Prefer run_onchange_, understand hash behavior |
| Newline before shebang (#9) | Use `{{-` whitespace-trimming syntax |
| Concurrent lock (#14) | Never call chezmoi from chezmoi scripts |

### Throughout All Phases
| Pitfall | Prevention |
|---------|------------|
| Missingkey errors (#11) | Test templates incrementally with execute-template |

---

## Quick Reference: First-Time User Checklist

Before adding your first file:
- [ ] `add.secrets = "error"` configured
- [ ] 1Password CLI installed and authenticated
- [ ] Editor configured with `--wait`/`-f` flag
- [ ] Shell aliases created (`ce`, `ca`, `cd-chezmoi`)
- [ ] File associations configured for `.tmpl` files

Before each `chezmoi apply`:
- [ ] Run `chezmoi diff` first
- [ ] Review any file deletions
- [ ] Check for unexpected changes in external directories

Before adding externals:
- [ ] External is reasonably small
- [ ] Cache paths identified for .chezmoiignore
- [ ] Understand you cannot `chezmoi add` inside external dirs

Before writing scripts:
- [ ] Use `run_onchange_` unless you need true run-once
- [ ] Use `{{-` syntax for shebang lines
- [ ] Script is idempotent
- [ ] Script does not call chezmoi

---

## Sources

### Official Documentation (HIGH confidence)
- [Chezmoi Troubleshooting FAQ](https://www.chezmoi.io/user-guide/frequently-asked-questions/troubleshooting/)
- [Chezmoi Usage FAQ](https://www.chezmoi.io/user-guide/frequently-asked-questions/usage/)
- [Chezmoi Design FAQ](https://www.chezmoi.io/user-guide/frequently-asked-questions/design/)
- [Chezmoi 1Password Integration](https://www.chezmoi.io/user-guide/password-managers/1password/)
- [Chezmoi Scripts Documentation](https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/)
- [Chezmoi Machine Differences](https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/)
- [Chezmoi Daily Operations](https://www.chezmoi.io/user-guide/daily-operations/)
- [Chezmoi Include Files from Elsewhere](https://www.chezmoi.io/user-guide/include-files-from-elsewhere/)
- [Chezmoi Templates Reference](https://www.chezmoi.io/reference/templates/)

### Community Resources (MEDIUM confidence)
- [Why chezmoi add Fails with Externals](https://mischavandenburg.com/zet/chezmoi-add-fails-with-externals/)
- [Getting the Most Out of chezmoi | HARIL](https://haril.dev/en/blog/2023/04/08/chezmoi-basic-settings)
- [PBS 123 - Chezmoi Templating](https://pbs.bartificer.net/pbs123)

### GitHub Discussions (MEDIUM confidence)
- [GitHub Discussion #1678 - run_once cache](https://github.com/twpayne/chezmoi/discussions/1678)
- [GitHub Discussion #4220 - .chezmoidata templates](https://github.com/twpayne/chezmoi/discussions/4220)
- [GitHub Issue #3745 - autoCommit/autoPush templating](https://github.com/twpayne/chezmoi/issues/3745)
