# Repository Guidelines

## Project Structure & Module Organization
- `init.lua` bootstraps LazyVim and primes the runtime path.
- `lua/config/{options,keymaps,autocmds,lazy}.lua` set core behavior and lazy.nvim bootstrap logic.
- `lua/plugins/*.lua` stores feature-scoped specs that return tables consumed by lazy.nvim.
- `lazy-lock.json` tracks plugin SHAs; update only after `:Lazy sync` when changes are deliberate.
- `stylua.toml` and `PLUGINS.md` capture formatting rules and contributor-facing plugin notes.

## Build, Test, and Development Commands
- `nvim --headless "+Lazy! sync" +qa` installs dependencies and verifies plugin specs compile.
- `nvim --headless "+checkhealth" +qa` reports missing binaries or runtime issues introduced by changes.
- `stylua lua` formats every module before committing.
- `rg "<pattern>" lua` is the preferred search tool when adjusting keymaps or autocmds.

## Coding Style & Naming Conventions
- Format with Stylua defaults: 2-space indent, 120-character lines, spaces over tabs.
- Keep plugin filenames kebab-case and aligned with their module paths; place helpers above the returned spec table.
- Prefer descriptive local names over inline lambdas and follow the leader-map patterns used in `lua/config/keymaps.lua`.

## Testing Guidelines
- Launch `nvim` interactively to smoke-test keymaps, UI tweaks, and LSP integrations you touched.
- Run `:Lazy check` (headless: `nvim --headless ":Lazy! check" +qa`) after any plugin spec change.
- Confirm new tooling installs inside `:Mason` when servers or adapters are added, and note OS prerequisites in your PR.
- Record manual validation steps so other agents can replay them.

## Commit & Pull Request Guidelines
- Use Conventional Commit prefixes (`feat:`, `fix:`, `chore:`) with concise, imperative subjects of ~72 characters.
- Keep commits focused; include `lazy-lock.json` only when bumping plugins intentionally and explain the reason.
- PRs must include a short summary, test notes, relevant screenshots for visual updates, and links to related issues or discussions.
- Request review once headless startup is clean and `stylua` passes locally.

## Agent Workflow Tips
- Jump to config modules with Legendary (`:Config`, `:Plugins`, `:PluginDocs`).
- Validate new leader bindings via `:Telescope keymaps` or `:map <leader>` to spot collisions early.
- When adding plugins, mirror the domain-based layout in `lua/plugins/` and update `PLUGINS.md` if user-facing behavior shifts.
