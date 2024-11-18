return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "helix",
    icons = {
      separator = "",
      keys = {
        Space = "Space"
      }
    },
    win = {
      border = "none",
      padding = { 1, 3 },
    },
    show_help = false
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
