return {
  -- Undo tree visualization
  {
    "mbbill/undotree",
    keys = {
      { "<leader>u", vim.cmd.UndotreeToggle, desc = "Toggle Undotree" },
    },
    config = function()
      vim.g.undotree_WindowLayout = 2
      vim.g.undotree_ShortIndicators = 1
      vim.g.undotree_SetFocusWhenToggle = 1
    end,
  },

  -- File explorer as a buffer
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-mini/mini.icons" },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
      { "<leader>oe", "<cmd>Oil<cr>", desc = "Open Oil file explorer" },
    },
    opts = {
      default_file_explorer = false,
      columns = { "icon", "permissions", "size", "mtime" },
      delete_to_trash = true,
    },
  },
}
