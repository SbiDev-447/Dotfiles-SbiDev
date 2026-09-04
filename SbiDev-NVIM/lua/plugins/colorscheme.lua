return {
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    lazy = false, -- Se carga bajo demanda
    config = function()
      require("kanagawa").setup({
        compile = false,
        undercurl = true,
        commentStyle = { italic = true },
        functionStyle = {},
        keywordStyle = { italic = true },
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = true, -- Fondo transparente
        dimInactive = false,
        terminalColors = true,
        colors = {
          palette = {},
          theme = {
            wave = {},
            lotus = {},
            dragon = {},
            all = {
              ui = {
                bg_gutter = "none",
                bg_sidebar = "none",
                bg_float = "none",
              },
            },
          },
        },
        overrides = function(colors)
          return {
            LineNr = { bg = "none" },
            NormalFloat = { bg = "none" },
            FloatBorder = { bg = "none" },
            FloatTitle = { bg = "none" },
            TelescopeNormal = { bg = "none" },
            TelescopeBorder = { bg = "none" },
            LspInfoBorder = { bg = "none" },
          }
        end,
        theme = "lotus",
        background = {
          dark = "wave",
          light = "lotus",
        },
      })
    end,
  },

  -- Tema principal (derivado de Kanagawa con efecto blur)
  {
    "Gentleman-Programming/gentleman-kanagawa-blur",
    name = "gentleman-kanagawa-blur",
    priority = 1000,
    -- No necesita config propia; solo usa los colores de kanagawa
  },

  -- LazyVim establece el colorscheme final
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "gentleman-kanagawa-blur",
    },
  },
}
