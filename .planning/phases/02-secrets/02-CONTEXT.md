# Phase 2: Secrets - Context

**Gathered:** 2026-01-18
**Status:** Ready for planning

<domain>
## Phase Boundary

1Password integration that provides secrets to all templated configs. SSH connections work via 1Password agent, Git commits are signed via 1Password, and templates can retrieve secrets via `onepasswordRead`. No local key files needed.

</domain>

<decisions>
## Implementation Decisions

### SSH agent setup
- Use 1Password's default socket location (~/.1password/agent.sock)
- Same SSH config on all devices (work and personal)
- No fallback to system agent — fail clearly if 1Password agent isn't running
- Configure GitHub as primary host, structure allows easy addition of other hosts later

### Git signing config
- Sign all commits globally (not per-repo)
- Same signing key everywhere (not device-specific)
- Reference signing key via 1Password item reference (op:// URI)
- Use SSH key format for signing (gpg.format = ssh)

### Verification approach
- `chezmoi diff` shows placeholder text (e.g., '[SECRET]') instead of actual secret values
- Verify SSH with both: 1Password agent check AND `ssh -T git@github.com`
- Signing verification: check git config only (no test commits)
- Automate verification via chezmoi run_after script

### Claude's Discretion
- Secret retrieval patterns (naming conventions, vault organization)
- Exact placeholder text format
- run_after script error handling approach

</decisions>

<specifics>
## Specific Ideas

No specific requirements — open to standard approaches

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 02-secrets*
*Context gathered: 2026-01-18*
