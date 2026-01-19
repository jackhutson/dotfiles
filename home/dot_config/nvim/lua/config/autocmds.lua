-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Disable spell checking in markdown files
vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Tame noisy diagnostics in Markdown buffers (keep signs/underlines, hide virtual text)
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("markdown_diagnostics_quiet", { clear = true }),
  pattern = { "markdown", "mdx" },
  callback = function()
    vim.diagnostic.config({ virtual_text = false, underline = true, signs = true })
  end,
})
