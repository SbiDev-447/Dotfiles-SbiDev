return {
  "selimacerbas/kitehost.nvim",
  dependencies = {
    "folke/which-key.nvim",
    "nvim-telescope/telescope.nvim", -- recomendado para el picker de paths
  },
  init = function()
    local ok, wk = pcall(require, "which-key")
    if ok then
      wk.add({ { "<leader>t", group = "KiteHost" } })
    end
  end,
  opts = {
    default_port = 5500,
    live_reload = {
      enabled = true,
      inject_script = true,
      debounce = 300,
      css_inject = true,
    },
    directory_listing = { enabled = true, show_hidden = false },
  },
  keys = {
    { "<leader>ts", "<cmd>KiteHost start<cr>", desc = "Start (pick path & port)" },
    { "<leader>to", "<cmd>KiteHost open<cr>", desc = "Open existing port in browser" },
    { "<leader>tr", "<cmd>KiteHost reload<cr>", desc = "Force reload (pick port)" },
    { "<leader>tt", "<cmd>KiteHost toggle-live<cr>", desc = "Toggle live-reload (pick port)" },
    { "<leader>ti", "<cmd>KiteHost status<cr>", desc = "Show server status" },
    { "<leader>tS", "<cmd>KiteHost stop<cr>", desc = "Stop one (pick port)" },
    { "<leader>tA", "<cmd>KiteHost stop-all<cr>", desc = "Stop all" },
  },
  config = function(_, opts)
    require("kitehost").setup(opts)
  end,
}
