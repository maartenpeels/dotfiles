-- Used by `git diffview` and `git bd` (see config/git/.config/git/commands)
return {
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    opts = {
      enhanced_diff_hl = true,
    },
  },
}
