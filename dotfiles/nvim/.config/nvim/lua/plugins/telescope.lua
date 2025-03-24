local builtin = require("telescope.builtin")

return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      {
        "<leader>/",
        function()
          local root = string.gsub(vim.fn.system("git rev-parse --show-toplevel"), "\n", "")
          if vim.v.shell_error == 0 then
            builtin.live_grep({ cwd = root })
          else
            builtin.live_grep({ root = true })
          end
        end,
        desc = "Grep (Git Dir)",
      },
      {
        "<leader><space>",
        function()
          local root = string.gsub(vim.fn.system("git rev-parse --show-toplevel"), "\n", "")
          if vim.v.shell_error == 0 then
            builtin.find_files({ cwd = root })
          else
            builtin.find_files({ root = true })
          end
        end,
        desc = "Find File (Git Dir)",
      },
      {
        "<leader>;",
        builtin.resume,
        desc = "Resume Telescope",
      },
    },
  },
}
