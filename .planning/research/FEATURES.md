# Features Research: Chezmoi for Multi-Device Dotfiles

**Domain:** Cross-platform dotfiles management
**Researched:** 2026-01-18
**Context:** 4 devices (2 macOS, 1 Arch Linux, Linux VMs), 1Password integration, device-specific configs

---

## Table Stakes

Features you must use or your multi-device setup will be broken or unmanageable.

| Feature | Why Required | Complexity | Notes |
|---------|--------------|------------|-------|
| **Templates (`.tmpl`)** | Core mechanism for device/OS differences. Without templates, you need separate files per machine. | Low | Go `text/template` syntax. Use `.chezmoi.os`, `.chezmoi.hostname` for conditionals. |
| **Config file (`chezmoi.toml`)** | Machine-specific data (email, device name, work vs personal flags). Each machine needs its own. | Low | Lives at `~/.config/chezmoi/chezmoi.toml`, NOT in repo. Define `[data]` section. |
| **`.chezmoi.toml.tmpl`** | Prompts user during `chezmoi init` to populate machine-specific config. Without this, manual config on each device. | Medium | Uses `promptStringOnce`, `promptBoolOnce`. Runs before source state is read. |
| **`.chezmoiignore`** | Exclude files per OS/device. E.g., kanata configs on macOS only, work tools on work laptop only. | Low | Supports templates for conditional ignoring: `{{ if ne .chezmoi.os "darwin" }}` |
| **1Password integration** | Secrets (API keys, tokens) must come from 1Password, not repo. Required for public/shared dotfiles. | Medium | Use `onepasswordRead` for simple values. Requires `op` CLI installed and authenticated. |
| **Run scripts (`run_*.sh`)** | Install dependencies (Brewfile on macOS, shell script on Arch). Chezmoi alone cannot install packages. | Medium | Prefer `run_onchange_` over `run_once_`. Make scripts idempotent. |
| **`chezmoi diff` and `chezmoi apply --dry-run`** | Preview changes before applying. Critical for avoiding destructive overwrites. | Low | ALWAYS run before `chezmoi apply` on new machine or after major changes. |

### Template Variables You Will Use

| Variable | Purpose | Example |
|----------|---------|---------|
| `.chezmoi.os` | OS detection | `darwin`, `linux` |
| `.chezmoi.hostname` | Device detection | Distinguish work laptop from personal |
| `.chezmoi.arch` | Architecture | `amd64`, `arm64` |
| Custom data | Your variables | `.email`, `.isWork`, `.machine` in config `[data]` |

### 1Password Functions

| Function | Use Case | Example |
|----------|----------|---------|
| `onepasswordRead` | Simple secret retrieval | `{{ onepasswordRead "op://Personal/GitHub/token" }}` |
| `onepasswordDetailsFields` | Field-level access | `{{ (onepasswordDetailsFields "uuid").password.value }}` |

---

## Differentiators

Features that improve workflow but are not strictly required. Add these after table stakes work.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| **`.chezmoidata.yaml`** | Shared static data committed to repo. Cleaner than putting everything in templates. | Low | Use for: list of tools to install, theme settings, non-sensitive shared config. |
| **`.chezmoitemplates/`** | Reusable template fragments. DRY principle for repeated patterns. | Medium | Good for: shell aliases used across `.bashrc`/`.zshrc`, common git configs. |
| **`.chezmoiexternal.toml`** | Pull external repos/archives (Oh My Zsh, plugins). Avoids submodules. | Medium | Use `git-repo` type for plugins, `archive` for releases. Set refresh schedule. |
| **`exact_` directories** | Full control over directory contents. Removes files not in source state. | Low | Use for: plugin directories, theme directories. NOT for dirs with cache files. |
| **`run_onchange_` scripts** | Re-run when script content changes. Better than `run_once_` in most cases. | Low | Use for: Brewfile (re-run when packages change), package lists. |
| **`run_before_` / `run_after_`** | Control script execution order. Ensure dependencies install before configs apply. | Low | Use `run_once_before_` for password manager setup before secrets are needed. |
| **Symlink mode** | For files modified by applications (VSCode settings). Changes visible without `chezmoi apply`. | Medium | Set `mode = "symlink"` in config. Cannot use for templates, encrypted, or private files. |
| **`chezmoi edit --watch`** | Auto-apply on save during development. Faster iteration. | Low | Use during initial setup/debugging. |
| **`chezmoi doctor`** | Diagnose configuration issues. | Low | Run after install, after major changes. |
| **`modify_` scripts** | Modify existing files instead of replacing. Good for files partially managed by apps. | High | Use for: adding lines to system files, INI files with app state. Complex, use sparingly. |
| **`create_` prefix** | Only create file if it doesn't exist. Good for initial templates. | Low | Use for: default configs that user customizes locally. |

### When to Use `.chezmoidata.yaml` vs Config `[data]`

| Data Type | Where to Put It | Why |
|-----------|-----------------|-----|
| Same across all machines | `.chezmoidata.yaml` | Committed to repo, single source of truth |
| Different per machine | `chezmoi.toml` `[data]` | Machine-specific, not in repo |
| Sensitive | Neither (use 1Password) | Never commit secrets |

---

## Anti-Features

Chezmoi features to explicitly NOT use, or use very carefully.

| Anti-Feature | Why Avoid | What to Do Instead |
|--------------|-----------|-------------------|
| **`run_once_` for package installs** | Tracks by content hash only. If you rename the script, it runs again. Easy to create confusion. | Use `run_onchange_` instead. It tracks filename AND content, more predictable. |
| **`run_` (always)** | Runs on every `chezmoi apply`. Wasteful for package installs. | Use `run_onchange_` for idempotent scripts that should run when content changes. |
| **Encrypting individual files with GPG** | Adds complexity, key management headaches, especially cross-device. | Use 1Password for secrets. Simpler, already have it. |
| **`chezmoi add` for files in external directories** | Chezmoi gets confused about path hierarchy. Creates broken paths. | Manually copy files to source state when dealing with externals. |
| **Auto-push to remote** | Sensitive files could accidentally be pushed. | Auto-commit is fine, but manually push after review. |
| **`exact_` on directories with cache files** | Chezmoi will delete cache/completion files on every apply. | Add cache paths to `.chezmoiignore`, or don't use `exact_`. |
| **Overly complex templates** | Go template syntax gets unreadable. Hard to debug, hard to maintain. | Split into `.chezmoitemplates/`, use clear variable names, comment heavily. |
| **`modify_` for simple use cases** | High complexity, script receives stdin/writes stdout. Easy to break. | Use templates unless you truly need to modify existing file content. |
| **Symlink mode for templates** | Symlinks cannot be templates. | Use copy mode (default) for any templated file. |
| **Direct editing in `~/.local/share/chezmoi`** | Easy to make mistakes, forget to commit. | Use `chezmoi edit` or `chezmoi cd` for explicit workflow. |

### Common Mistakes to Avoid

| Mistake | What Happens | Prevention |
|---------|--------------|------------|
| Editing managed file directly | Overwritten on next `chezmoi apply` | Use `chezmoi edit ~/.file` or `chezmoi re-add` after editing |
| Forgetting `--dry-run` | Unexpected file changes | Alias `chezmoi apply` to prompt or always use `chezmoi diff` first |
| Not making scripts idempotent | Scripts break on re-run, partial states | Test scripts can run multiple times safely |
| `.chezmoiignore` confusion | Ignores files FROM source, not TO target | Remember: patterns listed = NOT applied to target |
| Not running `chezmoi doctor` | Silent configuration issues | Run after install, after config changes |
| Using `re-add` on templates | Loses template markers, becomes static file | Never `re-add` template files. Use `chezmoi edit`. |

---

## Feature Dependencies

```
                    ┌─────────────────────────────────────────────┐
                    │           .chezmoi.toml.tmpl                │
                    │    (prompts during chezmoi init)            │
                    └────────────────┬────────────────────────────┘
                                     │
                                     ▼
                    ┌─────────────────────────────────────────────┐
                    │           chezmoi.toml                      │
                    │    (machine-specific data)                  │
                    └────────────────┬────────────────────────────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │                │                │
                    ▼                ▼                ▼
            ┌───────────┐    ┌───────────┐    ┌───────────────┐
            │ Templates │    │.chezmoi-  │    │ 1Password     │
            │ (.tmpl)   │    │ ignore    │    │ functions     │
            └───────────┘    └───────────┘    └───────────────┘
                    │                │                │
                    └────────────────┼────────────────┘
                                     │
                                     ▼
                    ┌─────────────────────────────────────────────┐
                    │           chezmoi apply                     │
                    │    (generates target state)                 │
                    └────────────────┬────────────────────────────┘
                                     │
                    ┌────────────────┼────────────────┐
                    ▼                                 ▼
        ┌───────────────────┐              ┌───────────────────┐
        │ run_before_*      │              │ File creation     │
        │ scripts           │              │ from templates    │
        └─────────┬─────────┘              └─────────┬─────────┘
                  │                                  │
                  ▼                                  ▼
        ┌───────────────────┐              ┌───────────────────┐
        │ run_after_*       │              │ External sources  │
        │ scripts           │              │ (if configured)   │
        └───────────────────┘              └───────────────────┘
```

### Critical Dependencies

| Feature | Requires | Notes |
|---------|----------|-------|
| Templates using custom data | `chezmoi.toml` with `[data]` | Data must exist before template execution |
| Templates using 1Password | `op` CLI installed + authenticated | Use `run_once_before_` to ensure `op` is ready |
| `.chezmoiignore` with conditions | `chezmoi.toml` data | Ignore patterns can reference custom data |
| `onepasswordRead` | `op` CLI, 1Password account | Fails if `op` not authenticated |
| `.chezmoiexternal.toml` | Network access | External fetches happen during apply |
| `run_onchange_` for Brewfile | Homebrew installed | Script should install Homebrew if missing |

### Recommended Dependency Order

1. **`run_once_before_install-op.sh`** - Install 1Password CLI (or verify it's installed)
2. **`chezmoi.toml`** populated via `.chezmoi.toml.tmpl` - Machine-specific data available
3. **Templates execute** - Can use both custom data and 1Password secrets
4. **`.chezmoiignore` evaluated** - Uses custom data for conditionals
5. **`run_onchange_after_install-packages.sh`** - Package installation after configs are in place

---

## MVP Recommendation

For your 4-device setup, prioritize in this order:

### Phase 1: Core Infrastructure (Must Have First)
1. **`.chezmoi.toml.tmpl`** - Prompt for: email, machine name, isWork boolean
2. **Basic templates** - `.gitconfig.tmpl` with email conditional
3. **`.chezmoiignore`** - OS-based ignoring (kanata on macOS only, work tools on work laptop)
4. **1Password integration** - At least one secret working (SSH key or API token)

### Phase 2: Package Management
1. **`run_onchange_after_darwin-packages.sh`** - Brewfile on macOS
2. **`run_onchange_after_linux-packages.sh`** - Package script on Arch
3. Both scripts should be idempotent

### Phase 3: Nice to Have
1. **`.chezmoidata.yaml`** - Shared configuration
2. **`.chezmoitemplates/`** - Reusable fragments
3. **`.chezmoiexternal.toml`** - External plugins/themes

### Defer to Post-MVP
- `modify_` scripts (too complex unless you have specific need)
- Symlink mode (adds complexity, not needed for most dotfiles)
- Full file encryption (use 1Password instead)

---

## Sources

- [Chezmoi Official Documentation](https://www.chezmoi.io/)
- [Chezmoi Templating Guide](https://www.chezmoi.io/user-guide/templating/)
- [1Password Integration](https://www.chezmoi.io/user-guide/password-managers/1password/)
- [Target Types Reference](https://www.chezmoi.io/reference/target-types/)
- [Managing Machine-to-Machine Differences](https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/)
- [Use Scripts to Perform Actions](https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/)
- [Script Differences Discussion](https://github.com/twpayne/chezmoi/discussions/4208)
- [Design FAQ](https://www.chezmoi.io/user-guide/frequently-asked-questions/design/)
- [Usage FAQ](https://www.chezmoi.io/user-guide/frequently-asked-questions/usage/)
- [Include Files from Elsewhere](https://www.chezmoi.io/user-guide/include-files-from-elsewhere/)
- [Protecting Secrets with Chezmoi](https://kidoni.dev/chezmoi-templates-and-secrets)
- [Managing dotfiles with Chezmoi - Nathaniel Landau](https://natelandau.com/managing-dotfiles-with-chezmoi/)
