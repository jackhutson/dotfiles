return {
  "dmmulroy/ts-error-translator.nvim",
  ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  config = function()
    require("ts-error-translator").setup({
      auto_attach = true,
    })
  end,
}
