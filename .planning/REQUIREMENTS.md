# Requirements: Dotfiles

**Defined:** 2026-01-20
**Core Value:** Fresh machine → productive dev environment in minutes, not hours.

## v1.1 Requirements

Fix v1 gaps so bootstrap actually delivers on the core value.

### Config Sync

- [ ] **SYNC-01**: Configs in chezmoi match current working machine (this machine)
- [ ] **SYNC-02**: Starship config is current working version (not regressed)
- [ ] **SYNC-03**: Zshrc is current working version with correct aliases

### Kanata

- [ ] **KANT-01**: Launchd plist file created for kanata service (macOS only)
- [ ] **KANT-02**: Post-apply output shows kanata launchctl command to run

### Claude Code

- [ ] **CLDE-01**: Broken Claude Code alias removed from zshrc
- [ ] **CLDE-02**: Post-apply output shows Claude Code install command

### Claude Config

- [ ] **CLCF-01**: `.claude` directory managed by chezmoi
- [ ] **CLCF-02**: MCP server configs synced across devices
- [ ] **CLCF-03**: Claude settings and custom commands synced

### Verification

- [ ] **VERF-01**: Verification script has no false positives
- [ ] **VERF-02**: Verification output is actionable (tells you what's wrong and how to fix)

### Post-Apply UX

- [ ] **POST-01**: Post-apply script shows clear "next steps" section
- [ ] **POST-02**: All manual commands are copy-pasteable
- [ ] **POST-03**: Steps are conditional (only show kanata on macOS, etc.)

### Prerequisites Documentation

- [ ] **DOCS-01**: Prerequisites listed with install commands or doc links
- [ ] **DOCS-02**: Karabiner Elements install/docs linked (kanata prerequisite)
- [ ] **DOCS-03**: 1Password CLI install/docs linked
- [ ] **DOCS-04**: Prerequisites shown in post-apply output if not detected

## v2 Considerations

Tracked but not in v1.1 scope.

### System Config

- **SYST-01**: macOS defaults script for system preferences
- **SYST-02**: Full Proxmox VM setup (beyond minimal)

### Future Tools

- **FUTR-01**: Nix/Home Manager migration (if chezmoi proves insufficient)
- **FUTR-02**: Browser extension sync documentation

## Out of Scope

| Feature | Reason |
|---------|--------|
| Automatic kanata installation | Manual install OK, just need launchd service |
| Browser extension automation | No good automation path, use browser sync |
| Zed/Helix configs | Testing only, not primary editors |
| Windows support | Not needed |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| SYNC-01 | TBD | Pending |
| SYNC-02 | TBD | Pending |
| SYNC-03 | TBD | Pending |
| KANT-01 | TBD | Pending |
| KANT-02 | TBD | Pending |
| CLDE-01 | TBD | Pending |
| CLDE-02 | TBD | Pending |
| CLCF-01 | TBD | Pending |
| CLCF-02 | TBD | Pending |
| CLCF-03 | TBD | Pending |
| VERF-01 | TBD | Pending |
| VERF-02 | TBD | Pending |
| POST-01 | TBD | Pending |
| POST-02 | TBD | Pending |
| POST-03 | TBD | Pending |
| DOCS-01 | TBD | Pending |
| DOCS-02 | TBD | Pending |
| DOCS-03 | TBD | Pending |
| DOCS-04 | TBD | Pending |

**Coverage:**
- v1.1 requirements: 19 total
- Mapped to phases: 0 (roadmap pending)
- Unmapped: 19

---
*Requirements defined: 2026-01-20*
*Last updated: 2026-01-20 after v1.1 milestone start*
