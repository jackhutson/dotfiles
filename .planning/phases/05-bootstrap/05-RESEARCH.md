# Phase 5: Bootstrap - Research

**Researched:** 2026-01-18
**Domain:** Shell scripting, OS detection, chezmoi installation
**Confidence:** HIGH

## Summary

Bootstrap scripts for dotfiles follow well-established patterns. The chezmoi project provides an official install script (`get.chezmoi.io`) that handles downloading the binary for any OS/arch combination. The standard pattern is a `curl | sh` one-liner that downloads a bootstrap script which then downloads chezmoi (if needed) and runs `chezmoi init --apply`.

Key findings:
- Chezmoi's official installer (`sh -c "$(curl -fsLS get.chezmoi.io)"`) is the standard way to install chezmoi
- OS detection uses `uname -s` returning `Darwin` for macOS and `Linux` for Linux
- The `set -euo pipefail` pattern provides robust error handling
- 1Password CLI is checked via `command -v op` combined with `op --version`

**Primary recommendation:** Use a single bootstrap.sh that checks prerequisites (git, curl, 1Password CLI), installs chezmoi via `get.chezmoi.io`, and runs `chezmoi init --apply`. Keep the script minimal and delegate all actual configuration to chezmoi.

## Standard Stack

The bootstrap phase uses only shell scripting and chezmoi's official installer:

### Core

| Tool | Purpose | Why Standard |
|------|---------|--------------|
| `get.chezmoi.io` | Chezmoi installation script | Official, maintained, handles all OS/arch |
| `uname -s` | OS detection | POSIX standard, reliable |
| `command -v` | Check command existence | POSIX standard, preferred over `which` |
| `curl` | Download scripts | Pre-installed on macOS, common on Linux |

### Supporting

| Tool | When Used | Notes |
|------|-----------|-------|
| `wget` | Fallback for curl | More common on minimal Linux installs |
| `op --version` | 1Password CLI check | Validates CLI is working, not just present |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Custom chezmoi download | `get.chezmoi.io` | Official script is maintained, handles edge cases |
| `which` for detection | `command -v` | `which` is not POSIX, inconsistent across shells |
| `$OSTYPE` | `uname -s` | `$OSTYPE` varies by shell, `uname` is universal |

## Architecture Patterns

### Recommended Script Structure

```bash
#!/bin/bash
set -euo pipefail

# Stage output helper
stage() {
    echo "[${1}/${TOTAL_STAGES}] ${2} ${3}"
}

# Check prerequisites
check_prerequisites() { ... }

# Install chezmoi
install_chezmoi() { ... }

# Run chezmoi
run_chezmoi() { ... }

# Main execution
main() {
    check_prerequisites
    install_chezmoi
    run_chezmoi
    print_summary
}

main
```

### Pattern 1: Staged Progress Output

**What:** Show progress with stage numbers and emoji indicators
**When to use:** User-facing bootstrap scripts
**Example:**
```bash
TOTAL_STAGES=4

stage() {
    local num="$1"
    local emoji="$2"
    local message="$3"
    echo "[${num}/${TOTAL_STAGES}] ${emoji} ${message}"
}

stage 1 "..." "Checking prerequisites"
# do work...
echo "  [ok]"
```

### Pattern 2: OS Detection

**What:** Detect macOS vs Linux using `uname -s`
**When to use:** Any cross-platform bootstrap script
**Example:**
```bash
# Source: POSIX standard
detect_os() {
    case "$(uname -s)" in
        Darwin*) echo "darwin" ;;
        Linux*)  echo "linux" ;;
        *)       echo "unknown" ;;
    esac
}

OS=$(detect_os)
if [ "$OS" = "unknown" ]; then
    echo "Error: Unsupported operating system"
    exit 1
fi
```

### Pattern 3: Command Existence Check

**What:** Check if a command is available
**When to use:** Prerequisite validation
**Example:**
```bash
# Source: POSIX standard
check_command() {
    if ! command -v "$1" &>/dev/null; then
        echo "Error: $1 is not installed"
        return 1
    fi
}

check_command git || exit 1
check_command curl || exit 1
```

### Pattern 4: Chezmoi Installation

**What:** Install chezmoi using official script
**When to use:** When chezmoi is not present
**Example:**
```bash
# Source: https://www.chezmoi.io/install/
install_chezmoi() {
    if command -v chezmoi &>/dev/null; then
        echo "  chezmoi already installed"
        return 0
    fi

    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
}
```

### Anti-Patterns to Avoid

- **Downloading chezmoi manually:** The `get.chezmoi.io` script handles architecture detection, checksums, and error cases. Never implement this yourself.
- **Using `which` for command detection:** Not POSIX compliant, behaves differently across shells.
- **Checking `$OSTYPE`:** Shell-specific variable, `uname -s` is universal.
- **Hardcoding chezmoi paths:** Use `command -v chezmoi` to find it regardless of installation location.

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Chezmoi installation | curl binary + chmod | `get.chezmoi.io` | Handles OS/arch detection, checksums, errors |
| OS detection | Complex distro detection | `uname -s` | Kernel name is sufficient for macOS vs Linux |
| Progress indicators | Complex terminal manipulation | Simple `echo` with `[n/m]` | Works in all terminals, easy to maintain |

**Key insight:** The bootstrap script should do the absolute minimum - check prerequisites, install chezmoi, run init. All configuration complexity belongs in chezmoi templates and scripts, not the bootstrap.

## Common Pitfalls

### Pitfall 1: Forgetting `set -euo pipefail`

**What goes wrong:** Script continues after failures, leading to partial/broken setups
**Why it happens:** Bash default is to continue after errors
**How to avoid:** Always start with `set -euo pipefail`
**Warning signs:** Script "completes" but machine is not configured

### Pitfall 2: Using `/bin/sh` When Bash Features Needed

**What goes wrong:** Syntax errors on systems where `/bin/sh` is dash or other shell
**Why it happens:** `pipefail` and some other features are bash-specific
**How to avoid:** Use `#!/bin/bash` shebang, not `#!/bin/sh`
**Warning signs:** "Illegal option -o pipefail" error

### Pitfall 3: Not Validating 1Password CLI is Working

**What goes wrong:** `command -v op` succeeds but `op` can't actually run (broken install)
**Why it happens:** Only checking presence, not functionality
**How to avoid:** Run `op --version` after checking presence
**Warning signs:** chezmoi apply fails with 1Password template errors

### Pitfall 4: curl | sh with Incomplete Downloads

**What goes wrong:** Network interruption causes partial script to execute
**Why it happens:** Shell starts executing as data arrives
**How to avoid:** Use `curl -fsLS` flags (fail silently on server errors, follow redirects, show errors, fail on HTTP errors)
**Warning signs:** Syntax errors or partial execution

### Pitfall 5: Not Handling Missing Prerequisites Gracefully

**What goes wrong:** Cryptic error messages when git/curl not installed
**Why it happens:** Assuming prerequisites exist
**How to avoid:** Check explicitly with clear error messages
**Warning signs:** "command not found" buried in output

### Pitfall 6: Forgetting to Add chezmoi to PATH

**What goes wrong:** chezmoi installed but not found
**Why it happens:** `get.chezmoi.io` installs to `./bin` by default
**How to avoid:** Use `-b "$HOME/.local/bin"` and ensure it's in PATH
**Warning signs:** "chezmoi: command not found" after successful install

## Code Examples

Verified patterns from official sources and best practices:

### Complete OS Detection

```bash
# Source: POSIX uname standard + community best practice
detect_os() {
    local kernel
    kernel=$(uname -s)

    case "$kernel" in
        Darwin)
            echo "darwin"
            ;;
        Linux)
            echo "linux"
            ;;
        *)
            echo "Error: Unsupported operating system: $kernel" >&2
            return 1
            ;;
    esac
}
```

### Prerequisite Validation

```bash
# Source: Community best practice
check_prerequisites() {
    local missing=()

    # Required commands
    for cmd in git curl; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done

    # 1Password CLI (required for secrets)
    if ! command -v op &>/dev/null; then
        missing+=("1password-cli (op)")
    elif ! op --version &>/dev/null 2>&1; then
        echo "Error: 1Password CLI is installed but not working"
        echo "  Run 'op --version' to diagnose"
        return 1
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        echo "Error: Missing required commands: ${missing[*]}"
        return 1
    fi
}
```

### Chezmoi Installation with Binary Path

```bash
# Source: https://www.chezmoi.io/install/
CHEZMOI_BIN="$HOME/.local/bin"

install_chezmoi() {
    # Ensure bin directory exists
    mkdir -p "$CHEZMOI_BIN"

    if command -v chezmoi &>/dev/null; then
        return 0
    fi

    # Install using official script with custom bin directory
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$CHEZMOI_BIN"

    # Verify installation
    if ! "$CHEZMOI_BIN/chezmoi" --version &>/dev/null; then
        echo "Error: chezmoi installation failed"
        return 1
    fi
}
```

### Chezmoi Init with Apply

```bash
# Source: https://www.chezmoi.io/reference/commands/init/
GITHUB_USER="jackhutson"
DOTFILES_REPO="dotfiles"

run_chezmoi_init() {
    # Use full path in case chezmoi not in PATH yet
    local chezmoi="${CHEZMOI_BIN}/chezmoi"

    "$chezmoi" init --apply "$GITHUB_USER/$DOTFILES_REPO"
}
```

### curl Flags Explained

```bash
# Source: curl man page + community best practice
# -f: Fail silently on HTTP errors (no HTML error pages)
# -s: Silent mode (no progress meter)
# -S: Show errors when -s is used
# -L: Follow redirects
curl -fsSL https://get.chezmoi.io
```

### Summary from External File

```bash
# Source: User decision in CONTEXT.md
print_summary() {
    local summary_file
    summary_file="$(dirname "$0")/SUMMARY.txt"

    if [ -f "$summary_file" ]; then
        echo ""
        cat "$summary_file"
    fi
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Manual chezmoi binary download | `get.chezmoi.io` install script | Always preferred | Automatic OS/arch detection |
| Using `which` | Using `command -v` | POSIX standardization | Portable across shells |
| `/bin/sh` for all scripts | `/bin/bash` when needed | When using bash features | Avoids dash/sh compatibility issues |

**Deprecated/outdated:**
- `git.io/chezmoi` shortener - Use `get.chezmoi.io` instead (more reliable)

## Open Questions

Things that couldn't be fully resolved:

1. **Chezmoi apply partial failure behavior**
   - What we know: Scripts that fail exit with non-zero status
   - What's unclear: Exact behavior when some templates succeed and others fail
   - Recommendation: Use `set -euo pipefail` in bootstrap, let chezmoi's default behavior handle apply. The existing `run_after_10-verify-secrets.sh.tmpl` already exits 1 on verification failure, providing clear error reporting.

2. **Exact GitHub raw URL**
   - What we know: Pattern is `https://raw.githubusercontent.com/{user}/{repo}/{branch}/{file}`
   - What's unclear: User's actual GitHub username (from CONTEXT.md: "jackhutson")
   - Recommendation: Verify GitHub username and repo name before finalizing

## Sources

### Primary (HIGH confidence)

- [Chezmoi Install Documentation](https://www.chezmoi.io/install/) - Official installation methods
- [Chezmoi Init Command Reference](https://www.chezmoi.io/reference/commands/init/) - `--apply`, `--one-shot` flags
- [POSIX uname specification](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/uname.html) - OS detection standard

### Secondary (MEDIUM confidence)

- [Safer Bash Scripts with set -euxo pipefail](https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/) - Error handling best practices
- [MIT SIPB Safe Shell Writing](https://sipb.mit.edu/doc/safe-shell/) - Shell scripting best practices
- [Bash OS Detection Patterns](https://safjan.com/bash-determine-if-linux-or-macos/) - uname -s usage patterns
- [felipecrs/dotfiles](https://github.com/felipecrs/dotfiles) - Real-world bootstrap example
- [RichiCoder1/dotfiles bootstrap.sh](https://github.com/RichiCoder1/dotfiles/blob/master/bootstrap.sh) - Real-world bootstrap example

### Tertiary (LOW confidence)

- Community discussions on chezmoi GitHub - Applied error handling patterns

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH - Official chezmoi docs, POSIX standards
- Architecture: HIGH - Based on official patterns and real-world examples
- Pitfalls: HIGH - Based on official docs and verified best practices

**Research date:** 2026-01-18
**Valid until:** 60 days (bootstrap patterns are stable)
