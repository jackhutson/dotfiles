return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.options.theme = require("catppuccin.utils.lualine")("mocha")
    end,
  },
}
