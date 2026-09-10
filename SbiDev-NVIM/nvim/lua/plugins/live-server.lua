return {
  "selimacerbas/live-server.nvim",
  opts = {
    default_port = 5500,
    live_reload = { enabled = true }, -- Activamos el live reload nativo
    directory_listing = { enabled = true, show_hidden = false },
    debounce = 300, -- Espera 300ms antes de recargar para no saturar
  },
  keys = {
    { "<leader>ts", "<cmd>LiveServerStart<cr>", desc = "Start (pick path & port)" },
    { "<leader>to", "<cmd>LiveServerOpen<cr>", desc = "Open existing port in browser" },
    { "<leader>tr", "<cmd>LiveServerReload<cr>", desc = "Force reload (pick port)" },
    { "<leader>tt", "<cmd>LiveServerToggleLive<cr>", desc = "Toggle live-reload (pick port)" },
    { "<leader>ti", "<cmd>LiveServerStatus<cr>", desc = "Show server status" },
    { "<leader>tS", "<cmd>LiveServerStop<cr>", desc = "Stop one (pick port)" },
    { "<leader>tA", "<cmd>LiveServerStopAll<cr>", desc = "Stop all" },
  },
}
