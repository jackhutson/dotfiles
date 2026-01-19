return {
  -- Enhanced git diff viewing and file history
  {
    "sindrets/diffview.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    cmd = {
      "DiffviewOpen",
      "DiffviewFileHistory",
      "DiffviewClose",
      "DiffviewRefresh",
      "DiffviewToggleFiles",
    },
    keys = {
      { "<leader>gD", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview" },
      { "<leader>gf", "<cmd>DiffviewFileHistory<cr>", desc = "File History" },
      { "<leader>gC", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        default = { layout = "diff2_horizontal" },
        merge_tool = { layout = "diff3_horizontal" },
      },
      file_panel = {
        listing_style = "tree",
        tree_options = {
          flatten_dirs = true,
          folder_statuses = "only_folded",
        },
        win_config = {
          position = "left",
          width = 35,
        },
      },
      file_history_panel = {
        log_options = {
          git = {
            single_file = {
              diff_merges = "combined",
            },
            multi_file = {
              diff_merges = "first-parent",
            },
          },
        },
        win_config = {
          position = "bottom",
          height = 16,
        },
      },
      commit_log_panel = {
        win_config = {
          position = "bottom",
          height = 16,
        },
      },
      default_args = {
        DiffviewOpen = {},
        DiffviewFileHistory = {},
      },
      hooks = {
        diff_buf_read = function(bufnr)
          -- Apply catppuccin integration
          vim.api.nvim_buf_set_option(bufnr, "wrap", false)
          vim.api.nvim_buf_set_option(bufnr, "list", false)
          vim.api.nvim_buf_set_option(bufnr, "colorcolumn", "")

          -- Register which-key descriptions for merge conflict navigation
          local ok, wk = pcall(require, "which-key")
          if ok then
            wk.add({
              { "]x", desc = "Next conflict", buffer = bufnr },
              { "[x", desc = "Previous conflict", buffer = bufnr },
              { "<leader>co", desc = "Choose ours (current)", buffer = bufnr },
              { "<leader>ct", desc = "Choose theirs (incoming)", buffer = bufnr },
              { "<leader>cb", desc = "Choose both", buffer = bufnr },
              { "<leader>cn", desc = "Choose none", buffer = bufnr },
            })
          end
        end,
      },
    },
  },

  -- GitHub Lite for PR review
  {
    "daliusd/ghlite.nvim",
    dependencies = {
      "sindrets/diffview.nvim", -- Works great together
      "nvim-tree/nvim-web-devicons",
    },
    cmd = {
      "GHLitePRSelect",
      "GHLitePRDiff",
      "GHLitePRAddComment",
      "GHLitePRApprove",
      "GHLitePRRequestChanges",
      "GHLitePRMerge",
    },
    keys = {
      { "<leader>gp", "<cmd>GHLitePRSelect<cr>", desc = "Select GitHub PR" },
      { "<leader>gP", "<cmd>GHLitePRDiff<cr>", desc = "View PR Diff" },
      { "<leader>ga", "<cmd>GHLitePRAddComment<cr>", desc = "Add PR Comment" },
      { "<leader>gA", "<cmd>GHLitePRApprove<cr>", desc = "Approve PR" },
      { "<leader>gr", "<cmd>GHLitePRRequestChanges<cr>", desc = "Request PR Changes" },
    },
    config = function()
      require("ghlite").setup({
        -- Use diffview for better diffs
        debug = false,
        view_split = "vsplit",
        diff_split = "vsplit",
        comment_split = "split",
        open_command = "edit",
      })
    end,
  },
}