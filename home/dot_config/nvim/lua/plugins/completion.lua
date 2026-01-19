-- Completion Configuration with blink.cmp
-- Using traditional vim keybinds: <C-n>/<C-p> for navigation, <C-y> to accept

return {
  {
    "saghen/blink.cmp",
    opts = {
      -- Ergonomic navigation: Tab cycles, Enter accepts, Esc cancels (fallback)
      keymap = {
        preset = "default",
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-y>"] = { "accept", "fallback" },
      },

      -- Inline preview tuned to show when an item is selected (avoids noisy first-item guesses)
      completion = {
        ghost_text = {
          enabled = true,
          show_with_selection = true,
          show_without_selection = false,
          show_with_menu = true,
          show_without_menu = true,
        },
        menu = {
          auto_show = true,
          auto_show_delay_ms = 75,
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 120,
        },
      },

      -- Favor structured sources and de-emphasize buffer words to cut English noise
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        providers = {
          buffer = {
            min_keyword_length = 3,
            score_offset = -3,
          },
        },
      },

      -- Appearance: use nerd fonts
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },

    },
  },
}
