# Phase 3: Core Configs - Research

**Researched:** 2026-01-18
**Domain:** Chezmoi shell configuration management (zsh, oh-my-zsh, starship)
**Confidence:** HIGH

## Summary

This phase migrates the user's existing shell configuration (zsh with oh-my-zsh, starship prompt, modular aliases, and tool integrations) into chezmoi management. The configuration includes work-only components (`it` tool wrapper and completion) that require conditional handling.

Chezmoi provides robust patterns for this use case:
1. **External dependencies** via `.chezmoiexternal.toml` for oh-my-zsh and its custom plugins
2. **Conditional file inclusion** via templated `.chezmoiignore` for work-only files
3. **Template conditionals** for device-specific content within files
4. **Modular organization** where alias files remain separate and are sourced by zshrc

The existing chezmoi setup (from Phase 2) already has `deviceType` and `isWork` variables configured in `.chezmoi.toml.tmpl`, providing the foundation for work/personal differentiation.

**Primary recommendation:** Use `.chezmoiexternal.toml` with `type = "archive"` for oh-my-zsh and custom plugins. Keep zshrc as a template (`dot_zshrc.tmpl`) with conditionals only for the `it` function section. Alias files remain static (non-templated) and modular under `.config/zsh/`.

## Standard Stack

The established approach for managing shell configs with chezmoi:

### Core
| Component | Approach | Purpose | Why Standard |
|-----------|----------|---------|--------------|
| oh-my-zsh | `.chezmoiexternal.toml` archive | Plugin framework | Official chezmoi docs recommend archive over git-repo |
| Custom plugins | `.chezmoiexternal.toml` archive | zsh-autosuggestions, etc. | Keeps plugins in sync, auto-updates |
| zshrc | `dot_zshrc.tmpl` | Main shell config | Needs template for device-specific sections |
| starship.toml | `dot_config/starship.toml` | Prompt config | Static file, no templating needed |
| Alias files | `dot_config/zsh/aliases-*.zsh` | Modular aliases | Static files, sourced conditionally at runtime |

### Supporting
| Component | Approach | When to Use |
|-----------|----------|-------------|
| `.chezmoiignore` | Templated | Exclude work-only files on personal devices |
| `.chezmoitemplates/` | Reusable snippets | If zshrc sections become complex |
| `run_onchange_` scripts | Post-apply hooks | If plugin install verification needed |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Archive for oh-my-zsh | `git-repo` type | git-repo keeps .git history but is heavier; archive is cleaner |
| Archive for plugins | Antigen/sheldon manager | Adds another tool; archive is simpler for fixed plugin set |
| Modular aliases | Single zshrc | Modularity aids maintenance; user already has this pattern |

**Installation:** No new packages needed. Chezmoi handles externals automatically.

## Architecture Patterns

### Recommended Source Directory Structure
```
home/
├── .chezmoiexternal.toml          # oh-my-zsh and plugins
├── .chezmoiignore                 # Conditional file exclusion
├── .chezmoi.toml.tmpl             # Device config (already exists)
├── .chezmoidata.toml              # Static data (already exists)
├── dot_zshrc.tmpl                 # Main zsh config (templated)
├── dot_zprofile                   # Homebrew shellenv (static)
├── dot_config/
│   ├── starship.toml              # Prompt config (static)
│   └── zsh/
│       ├── aliases-git.zsh        # Git aliases (static)
│       ├── aliases-tools.zsh      # Tool aliases (static)
│       ├── aliases-go.zsh         # Go aliases (static)
│       └── aliases-pnpm.zsh       # pnpm aliases (static)
├── private_dot_oh-my-zsh/
│   └── custom/
│       └── completions/
│           └── _it                # Work-only completion (conditional via .chezmoiignore)
└── private_dot_gitconfig.tmpl     # Already exists from Phase 2
```

### Pattern 1: External Dependencies for Oh-My-Zsh
**What:** Use `.chezmoiexternal.toml` to manage oh-my-zsh and custom plugins as archives
**When to use:** Always for oh-my-zsh and external zsh plugins
**Example:**
```toml
# Source: https://www.chezmoi.io/user-guide/include-files-from-elsewhere/

[".oh-my-zsh"]
type = "archive"
url = "https://github.com/ohmyzsh/ohmyzsh/archive/master.tar.gz"
exact = true
stripComponents = 1
refreshPeriod = "168h"

[".oh-my-zsh/custom/plugins/zsh-syntax-highlighting"]
type = "archive"
url = "https://github.com/zsh-users/zsh-syntax-highlighting/archive/master.tar.gz"
exact = true
stripComponents = 1
refreshPeriod = "168h"

[".oh-my-zsh/custom/plugins/zsh-autosuggestions"]
type = "archive"
url = "https://github.com/zsh-users/zsh-autosuggestions/archive/master.tar.gz"
exact = true
stripComponents = 1
refreshPeriod = "168h"

[".oh-my-zsh/custom/plugins/you-should-use"]
type = "archive"
url = "https://github.com/MichaelAquilina/zsh-you-should-use/archive/master.tar.gz"
exact = true
stripComponents = 1
refreshPeriod = "168h"
```

### Pattern 2: Conditional File Exclusion via .chezmoiignore
**What:** Template .chezmoiignore to exclude work-only files on personal devices
**When to use:** For files that should only exist on work devices
**Example:**
```
# Source: https://www.chezmoi.io/reference/special-files/chezmoiignore/

# Work-only files - ignore on personal devices
{{ if not .isWork }}
.oh-my-zsh/custom/completions/_it
{{ end }}
```

### Pattern 3: Template Conditionals in zshrc
**What:** Use Go template syntax to include/exclude sections based on device type
**When to use:** When file content differs between work and personal
**Example:**
```zsh
# Source: https://www.chezmoi.io/user-guide/templating/

{{ if .isWork }}
# ============================================================================
# Work Tools: crossnokaye/it - AWS profile management
# ============================================================================
IT_BIN="${GOBIN:-$HOME/go/bin}/it"
if [ ! -x "$IT_BIN" ] && command -v it >/dev/null 2>&1; then
  IT_BIN="$(command -v it)"
fi

it() {
  if [ "$1" = "env" ] && [ $# -eq 3 ]; then
    eval "$("$IT_BIN" env "$2" "$3")"
  else
    "$IT_BIN" "$@"
  fi
}

if [ -f "$HOME/.local/state/crossnokaye/it/env" ]; then
  export AWS_PROFILE=$(cat "$HOME/.local/state/crossnokaye/it/env")
fi

# Wire up completion if available
if [ -f "$ZSH/custom/completions/_it" ]; then
  autoload -Uz _it 2>/dev/null || true
  compdef _it it 2>/dev/null || true
fi
{{ end }}
```

### Pattern 4: Modular Alias Sourcing
**What:** Keep alias files separate, source them in zshrc
**When to use:** For maintainable, organized shell configuration
**Example:**
```zsh
# In dot_zshrc.tmpl - source modular alias files
[ -f ~/.config/zsh/aliases-git.zsh ] && source ~/.config/zsh/aliases-git.zsh
[ -f ~/.config/zsh/aliases-pnpm.zsh ] && source ~/.config/zsh/aliases-pnpm.zsh
[ -f ~/.config/zsh/aliases-go.zsh ] && source ~/.config/zsh/aliases-go.zsh
[ -f ~/.config/zsh/aliases-tools.zsh ] && source ~/.config/zsh/aliases-tools.zsh
```

### Anti-Patterns to Avoid
- **Don't use `git-repo` for oh-my-zsh:** Creates drift with oh-my-zsh's auto-update. Archive is cleaner.
- **Don't template every file:** Only use `.tmpl` when content actually differs. Static files are simpler.
- **Don't hardcode paths:** Use `$HOME` or chezmoi variables, not `/Users/jackhutson/`.
- **Don't put secrets in zshrc:** The current CONTEXT7_API_KEY should move to 1Password or be removed.

## Don't Hand-Roll

Problems that have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Oh-my-zsh installation | Manual git clone script | `.chezmoiexternal.toml` | Chezmoi handles clone, updates, caching |
| Plugin updates | Manual git pull scripts | `.chezmoiexternal.toml` with refreshPeriod | Automatic refresh on apply |
| Device detection | Custom hostname checks | `.chezmoi.toml.tmpl` with `deviceType` | Already exists, uses prompts |
| Conditional files | Complex template logic | `.chezmoiignore` | Cleaner than empty template output |
| Zsh completion setup | Manual fpath manipulation | Oh-my-zsh `custom/completions/` | Standard oh-my-zsh pattern |

**Key insight:** Chezmoi's `.chezmoiexternal.toml` eliminates the need for installation scripts for external dependencies. The archive approach with `refreshPeriod` handles both initial setup and updates declaratively.

## Common Pitfalls

### Pitfall 1: Oh-My-Zsh Auto-Update Drift
**What goes wrong:** Oh-my-zsh updates itself, causing chezmoi to see unexpected changes
**Why it happens:** Oh-my-zsh has built-in update mechanism that conflicts with chezmoi's declarative model
**How to avoid:** Set `DISABLE_AUTO_UPDATE="true"` in zshrc before sourcing oh-my-zsh
**Warning signs:** `chezmoi diff` shows changes in `.oh-my-zsh/` you didn't make

### Pitfall 2: Cache Directory Noise
**What goes wrong:** `chezmoi diff` constantly shows changes in cache directories
**Why it happens:** Oh-my-zsh caches completions and other data at runtime
**How to avoid:** Add cache paths to `.chezmoiignore`:
```
.oh-my-zsh/cache/
.oh-my-zsh/.git/
.cache/zsh/
```
**Warning signs:** Diff output showing `.oh-my-zsh/cache/completions/` changes

### Pitfall 3: Missing Custom Completions Directory
**What goes wrong:** Custom completion files (like `_it`) not loaded
**Why it happens:** The `custom/completions/` directory doesn't exist in oh-my-zsh archive
**How to avoid:** Create the directory structure in chezmoi source:
```
private_dot_oh-my-zsh/custom/completions/_it
```
Chezmoi will merge this with the external archive.
**Warning signs:** Tab completion not working for custom tools

### Pitfall 4: fpath Order Issues
**What goes wrong:** Custom completions not recognized by zsh
**Why it happens:** fpath must be set before `compinit` runs (which oh-my-zsh does)
**How to avoid:** The user's current pattern is correct - set fpath before sourcing oh-my-zsh:
```zsh
if [ -d "$ZSH/custom/completions" ]; then
  fpath=("$ZSH/custom/completions" $fpath)
fi
```
**Warning signs:** `_it` file exists but `compdef _it it` fails

### Pitfall 5: Hardcoded Paths in Templates
**What goes wrong:** Templates work on one machine but fail on others
**Why it happens:** Paths like `/Users/jackhutson/` hardcoded instead of using `$HOME`
**How to avoid:** Always use `$HOME` or `{{ .chezmoi.homeDir }}` in templates
**Warning signs:** "file not found" errors on fresh machines

### Pitfall 6: Secrets in Shell Config
**What goes wrong:** API keys committed to git
**Why it happens:** Convenience of having keys in zshrc
**How to avoid:**
- Use 1Password CLI plugin: `source ~/.config/op/plugins.sh`
- Or use environment files not tracked by chezmoi
- Current `CONTEXT7_API_KEY` in zshrc should be addressed
**Warning signs:** `chezmoi add --secrets=error` fails

## Code Examples

Verified patterns from official sources:

### Complete .chezmoiexternal.toml for Oh-My-Zsh Setup
```toml
# Source: https://www.chezmoi.io/user-guide/include-files-from-elsewhere/

# Oh My Zsh core
[".oh-my-zsh"]
type = "archive"
url = "https://github.com/ohmyzsh/ohmyzsh/archive/master.tar.gz"
exact = true
stripComponents = 1
refreshPeriod = "168h"

# Custom plugins (not included in oh-my-zsh by default)
[".oh-my-zsh/custom/plugins/zsh-syntax-highlighting"]
type = "archive"
url = "https://github.com/zsh-users/zsh-syntax-highlighting/archive/master.tar.gz"
exact = true
stripComponents = 1
refreshPeriod = "168h"

[".oh-my-zsh/custom/plugins/zsh-autosuggestions"]
type = "archive"
url = "https://github.com/zsh-users/zsh-autosuggestions/archive/master.tar.gz"
exact = true
stripComponents = 1
refreshPeriod = "168h"

[".oh-my-zsh/custom/plugins/you-should-use"]
type = "archive"
url = "https://github.com/MichaelAquilina/zsh-you-should-use/archive/master.tar.gz"
exact = true
stripComponents = 1
refreshPeriod = "168h"

# zsh-completions provides additional completion definitions
[".oh-my-zsh/custom/plugins/zsh-completions"]
type = "archive"
url = "https://github.com/zsh-users/zsh-completions/archive/master.tar.gz"
exact = true
stripComponents = 1
refreshPeriod = "168h"
```

### Updated .chezmoiignore with Shell Config Exclusions
```
# Source: https://www.chezmoi.io/reference/special-files/chezmoiignore/

# Repository metadata - never managed
README.md
LICENSE
.git/
.planning/

# Oh-my-zsh runtime artifacts - ignore everywhere
.oh-my-zsh/cache/
.oh-my-zsh/.git/
.oh-my-zsh/log/
.cache/zsh/

# macOS-only files
{{ if ne .chezmoi.os "darwin" }}
Library/
.config/karabiner/
Brewfile
{{ end }}

# Linux-only files
{{ if ne .chezmoi.os "linux" }}
.config/systemd/
{{ end }}

# Work-only files - ignore on personal devices
{{ if not .isWork }}
.oh-my-zsh/custom/completions/_it
{{ end }}
```

### zshrc Template Structure
```zsh
# Source: User's current ~/.zshrc adapted for chezmoi templating

# ============================================================================
# Environment Variables
# ============================================================================

export HISTFILE="$HOME/.cache/zsh/history"
export ZSH_COMPDUMP="$HOME/.cache/zsh/zcompdump-$ZSH_VERSION"
export SHELL_SESSIONS_DIR="$HOME/.cache/zsh/sessions"
export ZSH="$HOME/.oh-my-zsh"

# Ensure custom completions are in place before Oh My Zsh runs compinit
if [ -d "$ZSH/custom/completions" ]; then
  fpath=("$ZSH/custom/completions" $fpath)
fi

# Editor configuration
if [ -n "$NVIM" ]; then
  export VISUAL="nvr -cc split --remote-wait +'set bufhidden=wipe'"
  export EDITOR="nvr -cc split --remote-wait +'set bufhidden=wipe'"
else
  export VISUAL="{{ .editor.default }}"
  export EDITOR="{{ .editor.default }}"
fi

export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# ============================================================================
# Oh My Zsh Configuration
# ============================================================================

ZSH_THEME="robbyrussell"
DISABLE_AUTO_UPDATE="true"  # Let chezmoi manage updates
DISABLE_MAGIC_FUNCTIONS="true"

plugins=(
  git
  aws
  fzf
  kubectl
  docker
  extract
  colored-man-pages
  copypath
  copyfile
  web-search
  zsh-completions
  zsh-autosuggestions
  zsh-syntax-highlighting
  you-should-use
  vi-mode
)

source $ZSH/oh-my-zsh.sh

# ============================================================================
# Starship Prompt
# ============================================================================

eval "$(starship init zsh)"

{{ if .isWork }}
# ============================================================================
# Work Tools: crossnokaye/it - AWS profile management
# ============================================================================

IT_BIN="${GOBIN:-$HOME/go/bin}/it"
if [ ! -x "$IT_BIN" ] && command -v it >/dev/null 2>&1; then
  IT_BIN="$(command -v it)"
fi

it() {
  if [ "$1" = "env" ] && [ $# -eq 3 ]; then
    eval "$("$IT_BIN" env "$2" "$3")"
  else
    "$IT_BIN" "$@"
  fi
}

if [ -f "$HOME/.local/state/crossnokaye/it/env" ]; then
  export AWS_PROFILE=$(cat "$HOME/.local/state/crossnokaye/it/env")
fi

if [ -f "$ZSH/custom/completions/_it" ]; then
  autoload -Uz _it 2>/dev/null || true
  compdef _it it 2>/dev/null || true
fi
{{ end }}

# ============================================================================
# Aliases
# ============================================================================

[ -f ~/.config/zsh/aliases-git.zsh ] && source ~/.config/zsh/aliases-git.zsh
[ -f ~/.config/zsh/aliases-pnpm.zsh ] && source ~/.config/zsh/aliases-pnpm.zsh
[ -f ~/.config/zsh/aliases-go.zsh ] && source ~/.config/zsh/aliases-go.zsh
[ -f ~/.config/zsh/aliases-tools.zsh ] && source ~/.config/zsh/aliases-tools.zsh

# Claude CLI
alias claude="$HOME/.claude/local/claude"

# ============================================================================
# Tool Initializations
# ============================================================================

# NVM (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
[ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"

# FZF
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Zoxide (smarter cd)
eval "$(zoxide init zsh)"

# 1Password CLI plugins
[ -f "$HOME/.config/op/plugins.sh" ] && source "$HOME/.config/op/plugins.sh"

# Go-installed binaries
if [ -n "${GOBIN:-}" ] && [ -d "$GOBIN" ]; then
  case ":$PATH:" in (*":$GOBIN:"*) ;; (*) export PATH="$GOBIN:$PATH" ;; esac
elif [ -d "$HOME/go/bin" ]; then
  case ":$PATH:" in (*":$HOME/go/bin:"*) ;; (*) export PATH="$HOME/go/bin:$PATH" ;; esac
fi

# Local bin in PATH
export PATH="$HOME/.local/bin:$PATH"

# Zsh completion configuration
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{green}%B%d%b%f'
zstyle ':completion:*' menu select

# Git alias completions
compdef _git gmm=git-merge
compdef _git gunc=git-reset
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `git-repo` for oh-my-zsh | `archive` type | Always recommended | Cleaner, no drift |
| Manual plugin git clones | `.chezmoiexternal.toml` | chezmoi 2.0+ | Declarative management |
| Hostname-based conditionals | Data variables (`deviceType`) | Best practice | More flexible |
| Single monolithic zshrc | Modular sourced files | Community pattern | Better maintainability |

**Deprecated/outdated:**
- `DISABLE_UPDATE_PROMPT` - Use `DISABLE_AUTO_UPDATE` instead
- `upgrade_oh_my_zsh` command - Deprecated in favor of `omz update`

## Open Questions

Things that couldn't be fully resolved:

1. **CONTEXT7_API_KEY in zshrc**
   - What we know: Currently hardcoded in user's zshrc
   - What's unclear: Should this move to 1Password or environment file?
   - Recommendation: Move to 1Password or `.env` file not tracked by chezmoi

2. **Kiro shell integration**
   - What we know: User has `[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro ...)"`
   - What's unclear: Is this needed on all machines?
   - Recommendation: Keep as-is, conditional already handles missing tool

3. **PLAYWRIGHT_USERNAME in zshrc**
   - What we know: Work-related config hardcoded
   - What's unclear: Should this be in work-only section?
   - Recommendation: Move inside `{{ if .isWork }}` block or to 1Password

## Sources

### Primary (HIGH confidence)
- [chezmoi: Include files from elsewhere](https://www.chezmoi.io/user-guide/include-files-from-elsewhere/) - External dependencies documentation
- [chezmoi: Manage machine-to-machine differences](https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/) - Templating and conditionals
- [chezmoi: .chezmoiignore](https://www.chezmoi.io/reference/special-files/chezmoiignore/) - Conditional file exclusion
- [chezmoi: .chezmoiexternal format](https://www.chezmoi.io/reference/special-files/chezmoiexternal-format/) - Full external format spec
- [chezmoi: Use scripts to perform actions](https://www.chezmoi.io/user-guide/use-scripts-to-perform-actions/) - Script types and usage
- [chezmoi: Templating](https://www.chezmoi.io/user-guide/templating/) - Template syntax and functions

### Secondary (MEDIUM confidence)
- [Frictionless Dotfile Management With Chezmoi](https://marcusb.org/posts/2025/01/frictionless-dotfile-management-with-chezmoi/) - Best practices blog post
- [Managing External Dependencies with Chezmoi](https://stoeps.de/posts/2025/managing_external_dependencies_with_chezmoi/) - Real-world examples
- [chezmoi GitHub Issue #256](https://github.com/twpayne/chezmoi/issues/256) - Oh-my-zsh import discussion

### Tertiary (LOW confidence)
- Various dotfiles repositories on GitHub - Pattern examples

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Official chezmoi documentation is clear and comprehensive
- Architecture patterns: HIGH - Multiple official sources confirm approach
- Pitfalls: MEDIUM - Based on community reports and documentation warnings

**Research date:** 2026-01-18
**Valid until:** 60 days (chezmoi is stable, patterns unlikely to change)
