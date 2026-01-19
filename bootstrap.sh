#!/bin/bash
set -euo pipefail

# Bootstrap script for fresh machine setup
# Usage: curl -fsSL https://raw.githubusercontent.com/jackhutson/dotfiles/master/bootstrap.sh | sh

TOTAL_STAGES=4

stage() {
    local num="$1"
    local emoji="$2"
    local message="$3"
    echo "[$num/$TOTAL_STAGES] $emoji $message"
}

detect_os() {
    local os
    os=$(uname -s)
    case "$os" in
        Darwin)
            echo "darwin"
            ;;
        Linux)
            echo "linux"
            ;;
        *)
            echo "Error: Unsupported operating system: $os" >&2
            exit 1
            ;;
    esac
}

check_prerequisites() {
    local missing=()

    if ! command -v git &>/dev/null; then
        missing+=("git")
    fi

    if ! command -v curl &>/dev/null; then
        missing+=("curl")
    fi

    if ! command -v op &>/dev/null; then
        missing+=("op (1Password CLI)")
    else
        # Verify op actually works (not just present)
        if ! op --version &>/dev/null; then
            echo "Error: 1Password CLI (op) is installed but not working" >&2
            echo "  Run 'op --version' to diagnose" >&2
            exit 1
        fi
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        echo "Error: Missing required tools:" >&2
        for tool in "${missing[@]}"; do
            echo "  - $tool" >&2
        done
        exit 1
    fi
}

install_chezmoi() {
    if command -v chezmoi &>/dev/null; then
        echo "  chezmoi already installed"
        return 0
    fi

    # Ensure ~/.local/bin exists
    mkdir -p "$HOME/.local/bin"

    # Install chezmoi via official installer
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"

    # Verify installation
    if [ ! -x "$HOME/.local/bin/chezmoi" ]; then
        echo "Error: chezmoi installation failed" >&2
        exit 1
    fi
}

run_chezmoi_init() {
    # Use full path in case ~/.local/bin not in PATH yet
    local chezmoi_bin
    if command -v chezmoi &>/dev/null; then
        chezmoi_bin="chezmoi"
    else
        chezmoi_bin="$HOME/.local/bin/chezmoi"
    fi

    "$chezmoi_bin" init --apply jackhutson/dotfiles
}

print_summary() {
    local script_dir
    script_dir=$(dirname "$0")
    local summary_file="$script_dir/SUMMARY.txt"

    if [ -f "$summary_file" ]; then
        echo ""
        cat "$summary_file"
    fi
}

main() {
    local os
    os=$(detect_os)

    stage 1 "🔍" "Checking prerequisites"
    check_prerequisites
    echo "  ✅ OS: $os"

    stage 2 "📦" "Installing chezmoi"
    install_chezmoi
    echo "  ✅"

    stage 3 "🚀" "Running chezmoi init --apply"
    run_chezmoi_init
    echo "  ✅"

    stage 4 "🎉" "Complete"
    print_summary
}

main "$@"
