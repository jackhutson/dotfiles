# Phase 1: Foundation - Context

**Gathered:** 2026-01-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Chezmoi infrastructure that prompts for device identity and conditionally manages files. Handles device detection, conditional file ignoring based on OS and device type, source state organization, and secret prevention. 1Password integration is Phase 2.

</domain>

<decisions>
## Implementation Decisions

### Device identity model
- Two device types only: `work` and `personal`
- VMs treated same as personal machines
- Email derived from device type (no email prompt needed)
- Hostname auto-detected from system (no prompt)
- Work email and personal email hardcoded in chezmoi.toml.tmpl template

### Init experience
- Interactive menu for device type selection (work / personal)
- No default — device type selection is required, init fails if not chosen
- Re-init skips prompts if config already exists (only prompts if values missing)
- Minimal verbosity — just the prompts, no explanatory text

### Claude's Discretion
- `.chezmoiroot` structure and directory organization
- Exact conditional ignore patterns (`.chezmoiignore` templating)
- How `add.secrets = "error"` is configured
- Template syntax choices

</decisions>

<specifics>
## Specific Ideas

No specific requirements — open to standard chezmoi approaches.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 01-foundation*
*Context gathered: 2026-01-18*
