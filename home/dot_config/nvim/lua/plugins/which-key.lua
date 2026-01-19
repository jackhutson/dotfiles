-- Which-key custom group registrations
return {
  "folke/which-key.nvim",
  opts = function(_, opts)
    opts.spec = opts.spec or {}
    vim.list_extend(opts.spec, {
      { "<leader>l", group = "lsp" },
      { "<leader>y", group = "yank/copy" },
    })
    return opts
  end,
}
