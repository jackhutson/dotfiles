# Phase 1: Foundation - Research

**Researched:** 2026-01-18
**Domain:** Chezmoi infrastructure for device identity and conditional file management
**Confidence:** HIGH

## Summary

Phase 1 establishes the chezmoi foundation: prompting for device type during init, conditionally ignoring files based on OS and device type, organizing the source directory with `.chezmoiroot`, and preventing accidental secret commits. The standard approach is well-documented and stable.

The user has made specific decisions that simplify the implementation:
- Two device types only: `work` and `personal` (no VM type)
- Email derived from device type (no email prompt)
- Hostname auto-detected via `.chezmoi.hostname` (no prompt)
- Interactive menu selection for device type using `promptChoiceOnce`

**Primary recommendation:** Use `promptChoiceOnce` for device type selection, validate the choice with `fail`, derive email from device type in the template, and configure `add.secrets = "error"` immediately.

## Standard Stack

The established tools for this phase:

### Core

| Component | Version | Purpose | Why Standard |
|-----------|---------|---------|--------------|
| **Chezmoi** | 2.69.3+ | Dotfiles management | Industry standard, native templating, single binary |
| **Go text/template** | (built-in) | Template syntax | Built into chezmoi, always maintained |
| **TOML** | (built-in) | Config format | Most readable for dotfiles, native chezmoi support |

### Supporting

| Component | Purpose | When to Use |
|-----------|---------|-------------|
| **`.chezmoi.hostname`** | Auto-detect hostname | Always - no manual entry needed |
| **`.chezmoi.os`** | Auto-detect OS | Always - darwin/linux conditionals |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| TOML config | YAML config | YAML is more verbose, TOML is cleaner for simple key-value |
| `promptChoiceOnce` | `promptStringOnce` | Choice provides validation, String allows typos |

## Architecture Patterns

### Recommended Project Structure

Using `.chezmoiroot` to separate source state from repository metadata:

```
.dotfiles/
├── .chezmoiroot              # Contains: "home"
├── .git/
├── .planning/                # GSD planning (ignored by chezmoi)
├── README.md                 # Repository documentation
│
└── home/                     # Source state root
    ├── .chezmoi.toml.tmpl    # Config template with prompts
    ├── .chezmoidata.toml     # Static shared configuration
    └── .chezmoiignore        # Conditional file exclusions
```

### Pattern 1: Device Type Selection with Validation

**What:** Use `promptChoiceOnce` with `fail` to enforce selection.
**When to use:** Always for Phase 1 init experience.

```go-template
{{/* .chezmoi.toml.tmpl */}}
{{- $deviceTypeChoices := list "work" "personal" -}}
{{- $deviceType := promptChoiceOnce . "deviceType" "Device type" $deviceTypeChoices -}}

{{- if not $deviceType -}}
{{-   writeToStdout "Device type is required. Please run 'chezmoi init' again.\n" -}}
{{-   exit 1 -}}
{{- end -}}

{{/* Derive email from device type */}}
{{- $email := "" -}}
{{- if eq $deviceType "work" -}}
{{-   $email = "jack@work-domain.com" -}}
{{- else -}}
{{-   $email = "jack@personal-domain.com" -}}
{{- end -}}

[data]
    deviceType = {{ $deviceType | quote }}
    email = {{ $email | quote }}
    hostname = {{ .chezmoi.hostname | quote }}

[add]
    secrets = "error"
```

**Source:** [promptChoiceOnce](https://www.chezmoi.io/reference/templates/init-functions/promptChoiceOnce/), [exit function](https://www.chezmoi.io/reference/templates/init-functions/exit/)

### Pattern 2: Conditional Ignoring with Inverted Logic

**What:** Use `ne` (not equal) in `.chezmoiignore` since chezmoi includes everything by default.
**When to use:** Platform-specific and device-specific files.

```go-template
{{/* .chezmoiignore */}}

# Repository files never managed
README.md
LICENSE
.git/
.planning/

# macOS-only files - ignore on Linux
{{ if ne .chezmoi.os "darwin" }}
Library/
.config/karabiner/
Brewfile
{{ end }}

# Linux-only files - ignore on macOS
{{ if ne .chezmoi.os "linux" }}
.config/systemd/
.config/pacman/
{{ end }}

# Work-only files - ignore on personal devices
{{ if ne .deviceType "work" }}
.config/work-tools/
{{ end }}
```

**Key insight:** The logic is "when to IGNORE" not "when to INCLUDE". Use `ne` to ignore files when the condition does NOT match.

**Source:** [Manage machine-to-machine differences](https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/)

### Pattern 3: Static Shared Data

**What:** Use `.chezmoidata.toml` for values that are the same across all machines.
**When to use:** Package lists, theme settings, non-sensitive shared config.

```toml
# .chezmoidata.toml

[git]
    name = "Jack Hutson"
    defaultBranch = "main"

[editor]
    default = "nvim"
```

**Critical limitation:** `.chezmoidata.toml` cannot use templates. It is parsed before templates run.

**Source:** [.chezmoidata documentation](https://www.chezmoi.io/reference/special-files/chezmoidata-format/)

### Anti-Patterns to Avoid

- **Using `eq` instead of `ne` in `.chezmoiignore`:** Results in inverted behavior (files missing where expected)
- **Prompting for hostname:** Auto-detected via `.chezmoi.hostname`, no prompt needed
- **Prompting for email separately:** Derive from device type to reduce prompts
- **Skipping `add.secrets`:** Allows accidental secret commits to repository

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Device type menu | Custom prompt parsing | `promptChoiceOnce` | Built-in validation, handles edge cases |
| OS detection | Shell scripts | `.chezmoi.os` | Always available, no external dependencies |
| Hostname detection | Manual entry | `.chezmoi.hostname` | Auto-detected, consistent |
| Secret detection | Manual review | `add.secrets = "error"` | Automatic scanning, prevents commits |
| Config re-init | Manual file editing | `promptChoiceOnce` | Skips prompts if values exist |

**Key insight:** Chezmoi's init functions handle the "prompt once, remember forever" pattern automatically. Don't try to implement this logic manually.

## Common Pitfalls

### Pitfall 1: Inverted Logic in .chezmoiignore

**What goes wrong:** Writing `{{ if eq .chezmoi.os "darwin" }}` to include macOS files, when you should use `{{ if ne .chezmoi.os "darwin" }}` to ignore on non-macOS.

**Why it happens:** Mental model conflict - we think "include this on macOS" but chezmoi thinks "ignore this unless..."

**How to avoid:** Remember the rule: `.chezmoiignore` lists what to EXCLUDE. Use `ne` (not equal) for platform-specific files.

**Warning signs:** Files appearing on wrong platform, files missing on expected platform.

**Verification:** Run `chezmoi ignored` to see actual ignored files on current machine.

### Pitfall 2: macOS Hostname Instability

**What goes wrong:** `.chezmoi.hostname` returns different values depending on network connection on macOS.

**Why it happens:** macOS `hostname` command is network-dependent.

**How to avoid:** For this use case (device type selection), hostname variability doesn't matter since we prompt for device type explicitly. If hostname-based conditionals are needed later, use `scutil`:

```go-template
{{ $computerName := output "scutil" "--get" "ComputerName" | trim }}
```

**Warning signs:** Config behaving differently on same machine in different network environments.

### Pitfall 3: Empty promptChoice Returns Empty String

**What goes wrong:** User presses Enter without selecting, `promptChoiceOnce` returns empty string, template continues with invalid data.

**Why it happens:** No built-in "required" validation in prompt functions.

**How to avoid:** Validate after prompt, use `exit 1` to abort:

```go-template
{{- if not $deviceType -}}
{{-   writeToStdout "Device type is required.\n" -}}
{{-   exit 1 -}}
{{- end -}}
```

**Warning signs:** Config file created with empty values, downstream templates failing.

### Pitfall 4: .chezmoidata Cannot Use Templates

**What goes wrong:** Attempting `{{ .chezmoi.os }}` in `.chezmoidata.toml` results in literal text, not evaluated value.

**Why it happens:** Data files provide values FOR templates, they cannot BE templates (chicken-egg problem).

**How to avoid:** Use `.chezmoidata.toml` only for truly static values. Use `.chezmoi.toml.tmpl` for computed values during init.

**Warning signs:** Template syntax appearing literally in output files.

### Pitfall 5: Forgetting add.secrets Configuration

**What goes wrong:** `chezmoi add` accepts files containing secrets without warning, secrets end up in git history.

**Why it happens:** Default `add.secrets = "warning"` only warns, doesn't prevent.

**How to avoid:** Set `add.secrets = "error"` in config immediately during Phase 1.

**Warning signs:** Seeing warnings during `chezmoi add` that are easy to dismiss.

## Code Examples

Verified patterns from official sources:

### Complete .chezmoi.toml.tmpl for Phase 1

```go-template
{{/* .chezmoi.toml.tmpl - Device configuration with prompts */}}

{{/* Device type selection - required, no default */}}
{{- $deviceTypeChoices := list "work" "personal" -}}
{{- $deviceType := promptChoiceOnce . "deviceType" "Device type" $deviceTypeChoices -}}

{{/* Validate device type was selected */}}
{{- if not $deviceType -}}
{{-   writeToStdout "ERROR: Device type is required. Run 'chezmoi init' again.\n" -}}
{{-   exit 1 -}}
{{- end -}}

{{/* Derive email from device type - no separate prompt */}}
{{- $email := "" -}}
{{- if eq $deviceType "work" -}}
{{-   $email = "jack@work-domain.com" -}}
{{- else -}}
{{-   $email = "jack@personal-domain.com" -}}
{{- end -}}

[data]
    deviceType = {{ $deviceType | quote }}
    email = {{ $email | quote }}
    hostname = {{ .chezmoi.hostname | quote }}
    isWork = {{ eq $deviceType "work" }}

[add]
    secrets = "error"
```

**Source:** [Setup Guide](https://www.chezmoi.io/user-guide/setup/), [promptChoiceOnce](https://www.chezmoi.io/reference/templates/init-functions/promptChoiceOnce/)

### Complete .chezmoiignore for Phase 1

```go-template
{{/* .chezmoiignore - Conditional file exclusions */}}

# Repository metadata - never managed
README.md
LICENSE
.git/
.planning/

# macOS-only files - ignore on non-macOS
{{ if ne .chezmoi.os "darwin" }}
Library/
.config/karabiner/
.config/kanata/
Brewfile
{{ end }}

# Linux-only files - ignore on non-Linux
{{ if ne .chezmoi.os "linux" }}
.config/systemd/
.config/pacman/
{{ end }}

# Work-only files - ignore on personal devices
{{ if ne .deviceType "work" }}
.config/work-tools/
{{ end }}

# Personal-only files - ignore on work devices
{{ if ne .deviceType "personal" }}
.config/personal-apps/
{{ end }}
```

**Source:** [Manage machine-to-machine differences](https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/)

### .chezmoiroot File

```
home
```

Single line, no template syntax. Points to `home/` subdirectory.

**Source:** [.chezmoiroot documentation](https://www.chezmoi.io/reference/special-files/chezmoiroot/)

### .chezmoidata.toml for Static Data

```toml
# .chezmoidata.toml - Static shared configuration
# NOTE: This file cannot use templates

[git]
    name = "Jack Hutson"
    defaultBranch = "main"

[editor]
    default = "nvim"
```

**Source:** [.chezmoidata documentation](https://www.chezmoi.io/reference/special-files/chezmoidata-format/)

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `promptString` for choices | `promptChoiceOnce` for menus | chezmoi 2.x | Built-in validation, better UX |
| Manual secret review | `add.secrets = "error"` | chezmoi 2.x | Automatic prevention |
| Flat source directory | `.chezmoiroot` for organization | Early chezmoi | Cleaner repos with metadata |

**Deprecated/outdated:**
- GPG encryption for secrets: Use 1Password instead (Phase 2)
- Manual hostname prompts: Use `.chezmoi.hostname` auto-detection

## Open Questions

Things that couldn't be fully resolved:

1. **Re-init with --prompt flag behavior**
   - What we know: `chezmoi init --prompt` forces re-prompting even if values exist
   - What's unclear: Exact UX when user wants to change device type after initial setup
   - Recommendation: Document `chezmoi init --prompt` as the way to change device type

2. **Device type change workflow**
   - What we know: `promptChoiceOnce` won't re-prompt if value exists
   - What's unclear: Whether deleting config or using `--prompt` is cleaner
   - Recommendation: Use `chezmoi init --prompt` to force re-selection

## Sources

### Primary (HIGH confidence)
- [chezmoi Setup Guide](https://www.chezmoi.io/user-guide/setup/) - Init template patterns
- [promptChoiceOnce reference](https://www.chezmoi.io/reference/templates/init-functions/promptChoiceOnce/) - Menu selection syntax
- [.chezmoiroot reference](https://www.chezmoi.io/reference/special-files/chezmoiroot/) - Source directory organization
- [.chezmoidata reference](https://www.chezmoi.io/reference/special-files/chezmoidata-format/) - Static data files
- [Manage machine-to-machine differences](https://www.chezmoi.io/user-guide/manage-machine-to-machine-differences/) - Conditional ignoring
- [Configuration file variables](https://www.chezmoi.io/reference/configuration-file/variables/) - add.secrets configuration
- [Template variables](https://www.chezmoi.io/reference/templates/variables/) - Built-in .chezmoi.* variables
- [exit function](https://www.chezmoi.io/reference/templates/init-functions/exit/) - Template abort mechanism

### Secondary (MEDIUM confidence)
- [GitHub Discussion #1670](https://github.com/twpayne/chezmoi/discussions/1670) - fail template function usage
- Prior research in `.planning/research/` - ARCHITECTURE.md, PITFALLS.md, FEATURES.md

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Official chezmoi documentation verified
- Architecture: HIGH - Patterns from official docs and established repos
- Pitfalls: HIGH - Documented in official FAQ and verified via research

**Research date:** 2026-01-18
**Valid until:** 2026-02-18 (30 days - chezmoi is stable, infrequent breaking changes)
