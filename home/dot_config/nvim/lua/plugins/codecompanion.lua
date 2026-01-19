return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "MunifTanjim/nui.nvim",
    },
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions", "CodeCompanionInline" },
    keys = {
      { "<leader>ac", "<cmd>CodeCompanionChat<cr>", desc = "AI Chat" },
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "AI Actions" },
      { "<leader>ai", "<cmd>CodeCompanionInline<cr>", mode = { "n", "v" }, desc = "AI Inline Edit" },
    },
    opts = function()
      return {
        opts = { log_level = "WARN" },
        strategies = {
          chat = { adapter = "claude_code" },
          inline = { adapter = "claude_code" },
        },
        adapters = {
          acp = {
            -- Uses Claude desktop subscription via ACP; no API key required
            claude_code = "claude_code",
          },
        },
      }
    end,
  },
}
