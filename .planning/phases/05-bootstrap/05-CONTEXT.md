# Phase 5: Bootstrap - Context

**Gathered:** 2026-01-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Single-command fresh machine setup — from nothing to fully configured dev environment. Script detects OS, installs chezmoi if needed, and runs full configuration. Does not include ongoing maintenance or update workflows.

</domain>

<decisions>
## Implementation Decisions

### Invocation Method
- curl | sh pattern: `curl -fsSL https://raw.githubusercontent.com/jackhutson/dotfiles/master/bootstrap.sh | sh`
- Hosted at GitHub raw URL (simplest, no extra infrastructure)
- No flags — script runs with sensible defaults, no customization options
- Prerequisites (git, curl) must be present — fail with clear error if missing

### Output & Progress
- Minimal output with stage indicators
- Format: `[1/4] 📦 Installing chezmoi... ✅` (stage count + emoji prefix + checkmark)
- Errors show message only — no automatic verbose output
- Brief summary at end from separate file (easy to maintain)
- Summary read from a SUMMARY.txt or similar — not hardcoded in script

### Error Handling
- Fail immediately on chezmoi installation failure (no retry)
- Strict mode: `set -euo pipefail` — exit on any error, unset var, or pipe failure
- 1Password CLI required — fail if `op` not installed
- chezmoi apply partial failures: Claude's discretion based on chezmoi behavior

### Claude's Discretion
- chezmoi apply partial failure handling (continue vs exit based on chezmoi defaults)
- Exact stage count and stage names
- Summary file location and format
- Any OS-specific detection logic details

</decisions>

<specifics>
## Specific Ideas

- Keep summary simple and maintainable — just a documented list, not dynamic detection
- User expects to run this on fresh macOS, CachyOS, and Linux VMs

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 05-bootstrap*
*Context gathered: 2026-01-18*
