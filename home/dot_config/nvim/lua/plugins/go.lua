return {
  -- Disable staticcheck in gopls (we'll use golangci-lint-langserver instead)
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              staticcheck = false,
            },
          },
        },
        -- Add golangci-lint-langserver for linting (respects .golangci.yaml)
        golangci_lint_ls = {},
      },
    },
  },
  -- Ensure golangci-lint-langserver is installed via Mason
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "golangci-lint-langserver" },
    },
  },
}
