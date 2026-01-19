return {
  -- Conform: format-on-save and formatter preferences
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts = opts or {}
      local util = require("conform.util")

      -- Define ESLint config files once for reuse
      local eslint_config_files = {
        "eslint.config.js",
        "eslint.config.mjs",
        "eslint.config.cjs",
        ".eslintrc",
        ".eslintrc.js",
        ".eslintrc.cjs",
        ".eslintrc.json",
        ".eslintrc.yaml",
        ".eslintrc.yml",
      }

      -- Formatters by filetype: use stop_after_first for conditional selection
      -- For JS/TS: tries eslint_d -> prettier (stops at first with valid condition)
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
        javascript = { "eslint_d", "prettier", stop_after_first = true },
        javascriptreact = { "eslint_d", "prettier", stop_after_first = true },
        typescript = { "eslint_d", "prettier", stop_after_first = true },
        typescriptreact = { "eslint_d", "prettier", stop_after_first = true },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        markdown = { "prettier" },
        mdx = { "prettier" },
      })

      -- Formatter fine-tuning: prefer local project binaries and correct cwd
      opts.formatters = vim.tbl_deep_extend("force", opts.formatters or {}, {
        eslint_d = {
          prefer_local = "node_modules/.bin",
          cwd = util.root_file(vim.list_extend(vim.deepcopy(eslint_config_files), { "package.json" })),
          -- Only run if ESLint config exists
          condition = function(self, ctx)
            return util.root_file(eslint_config_files)(self, ctx) ~= nil
          end,
        },
        prettier = {
          prefer_local = "node_modules/.bin",
          cwd = util.root_file({
            "package.json",
            ".prettierrc",
            ".prettierrc.json",
            ".prettierrc.js",
            ".prettierrc.cjs",
            ".prettierrc.mjs",
            ".prettierrc.yaml",
            ".prettierrc.yml",
            "prettier.config.js",
            "prettier.config.cjs",
            "prettier.config.mjs",
            "prettier.config.ts",
          }),
          -- Only run if NO ESLint config exists (fallback formatter for JS/TS)
          condition = function(self, ctx)
            local has_eslint = util.root_file(eslint_config_files)(self, ctx)
            return not has_eslint
          end,
        },
      })

      -- Note: Don't set opts.format_on_save here - LazyVim handles it automatically
      -- Our conditional formatters_by_ft will be called by LazyVim's format-on-save

      return opts
    end,
  },

  -- nvim-lint: reduce noisy markdown diagnostics (we rely on formatting instead)
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts = opts or {}
      opts.linters_by_ft = opts.linters_by_ft or {}
      -- Disable markdown linters unless you explicitly add them back later
      opts.linters_by_ft.markdown = {}
      opts.linters_by_ft.mdx = {}
      return opts
    end,
  },
}
