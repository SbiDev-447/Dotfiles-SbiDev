return {
  "saghen/blink.cmp",
  event = "InsertEnter",
  opts = {
    keymap = {
      preset = "enter", -- Enter sigue aceptando la sugerencia
      -- Tab: si el menú está abierto, salta a la siguiente sugerencia.
      -- Si no, salta al siguiente hueco del snippet.
      ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
      -- Shift+Tab: lo mismo pero hacia atrás.
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
    },
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
}
