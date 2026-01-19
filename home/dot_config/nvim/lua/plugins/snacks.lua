-- Snacks.nvim: pickers, LazyGit, and git links
return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        enabled = true,
      },
      lazygit = {
        configure = true,
      },
      gitbrowse = {},
    },
    keys = {
      -- LazyGit (preferred bindings)
      { "<leader>gn", function() Snacks.lazygit() end, desc = "LazyGit" },
      { "<leader>gN", function() Snacks.lazygit.log() end, desc = "LazyGit Log" },
      { "<leader>glf", function() Snacks.lazygit.log_file() end, desc = "LazyGit File History" },
      { "<leader>gy", function() Snacks.gitbrowse() end, mode = { "n", "v" }, desc = "Copy Git Link" },
      { "<leader>gY", function() Snacks.gitbrowse({ open = true }) end, mode = { "n", "v" }, desc = "Open Git Link" },
      -- Disable duplicate LazyGit bindings from defaults
      { "<leader>gg", false },
      { "<leader>gG", false },

      -- LSP-powered pickers
      { "<leader>ld", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
      { "<leader>lD", function() Snacks.picker.diagnostics() end, desc = "Workspace Diagnostics" },
      { "<leader>lr", function() Snacks.picker.lsp_references() end, desc = "LSP References" },
      { "<leader>ls", function() Snacks.picker.lsp_symbols() end, desc = "Document Symbols" },
      { "<leader>lS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Workspace Symbols" },
      { "<leader>li", function() Snacks.picker.lsp_implementations() end, desc = "LSP Implementations" },
      { "<leader>lt", function() Snacks.picker.lsp_type_definitions() end, desc = "Type Definitions" },
    },
  },
}
