# Custom Git Aliases
# Note: Most git aliases are provided by Oh-My-Zsh git plugin

# Fetch and merge main branch
alias gmm='git fetch origin main && git merge origin/main'

# Undo last commit but keep changes staged
alias gunc='git reset --soft HEAD~1'

alias gbcopy='git rev-parse --abbrev-ref HEAD | pbcopy && echo "✅ Branch copied to clipboard!"'

# Lists the N most recently checked-out git branches (default: 5)
# Usage: gbrl [number]           - List recent branches
#        gbrl -i [number]        - Interactive mode with fzf (select to copy to clipboard)
#        gbrl --interactive [N]  - Same as -i
gbrl() {
  # Check if in a git repository
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print -P "%F{yellow}⚠ Not in a git repository%f" >&2
    return 1
  fi

  # Parse flags for interactive mode
  local interactive=false
  if [[ "$1" == "-i" || "$1" == "--interactive" ]]; then
    interactive=true
    shift
  fi

  # Get the list of recently checked-out branches
  local branches
  branches=$(git reflog \
    | grep 'checkout:' \
    | awk '{print $NF}' \
    | awk '!seen[$0]++' \
    | head -n ${1:-5})

  # Interactive mode: use fzf to select and copy to clipboard
  if [[ "$interactive" == true ]]; then
    if ! command -v fzf > /dev/null 2>&1; then
      print -P "%F{red}✗ fzf is not installed%f" >&2
      print -P "Install with: brew install fzf" >&2
      return 1
    fi

    local selected
    selected=$(echo "$branches" | fzf --height=40% --reverse --prompt="Select branch to copy: ")

    if [[ -n "$selected" ]]; then
      echo -n "$selected" | pbcopy
      print -P "✅ Branch '$selected' copied to clipboard!"
    else
      print -P "%F{yellow}No branch selected%f" >&2
      return 1
    fi
  else
    # Simple mode: just list the branches
    echo "$branches"
  fi
}
