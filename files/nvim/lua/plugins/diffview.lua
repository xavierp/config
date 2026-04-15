return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
      {
        "<leader>gd",
        function()
          local base = vim.fn.system("git rev-parse --verify origin/main 2>/dev/null"):gsub("%s+", "")
          if base == "" then
            base = vim.fn.system("git rev-parse --verify origin/master 2>/dev/null"):gsub("%s+", "")
          end
          if base == "" then
            vim.notify("No origin/main or origin/master found", vim.log.levels.ERROR)
            return
          end
          vim.cmd("DiffviewOpen " .. base .. "...HEAD")
        end,
        desc = "Diff against default branch",
      },
      { "<leader>gD", "<cmd>DiffviewOpen<cr>", desc = "Diff working changes" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "File history (current)" },
      { "<leader>gF", "<cmd>DiffviewFileHistory<cr>", desc = "File history (all)" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close diffview" },
    },
    opts = {
      view = {
        default = { layout = "diff2_horizontal" },
      },
    },
  },
}
