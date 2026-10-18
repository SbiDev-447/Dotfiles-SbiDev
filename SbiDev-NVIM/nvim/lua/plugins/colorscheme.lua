return {
  {
    "ellisonleao/gruvbox.nvim",
    priority = 1000, -- Carga antes que LazyVim
    lazy = false, -- Asegura que esté disponible siempre
    opts = {
      contrast = "soft", -- "hard", "soft" o vacío
      italic = {
        strings = true,
        comments = true,
        folds = true,
        operators = false,
      },
      bold = true,
      underline = true,
      undercurl = true,
      transparent_mode = false,
      overrides = {
        LineNr = { bg = "none" },
        NormalFloat = { bg = "none" },
        FloatBorder = { bg = "none" },
        FloatTitle = { bg = "none" },
        TelescopeNormal = { bg = "none" },
        TelescopeBorder = { bg = "none" },
        LspInfoBorder = { bg = "none" },
      },
    },
  },
  {
    "rebelot/kanagawa.nvim",
    priority = 1000,
    lazy = false, -- Activo Antes que todo
    config = function()
      require("kanagawa").setup({
        compile = true,
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
        theme = "dragon",
        background = {
          dark = "dragon",
          light = "lotus",
        },
      })
    end,
  },

  -- Tema principal (derivado de Kanagawa con efecto blur)
  {
    "Gentleman-Programming/gentleman-kanagawa-blur",
    name = "gentleman-kanagawa-blur",
    priority = 999,
    dependencies = { "rebelot/kanagawa.nvim" },
    -- No necesita config propia; solo usa los colores de kanagawa
  },

  -- LazyVim establece el colorscheme final
  -- El bloque BEGIN_NVIM_THEME lo commuta toggle-theme-nvim.sh.
  -- background debe fijarse ANTES del colorscheme: gruvbox lee vim.o.background
  -- al cargar y usa esa misma paleta para light y dark.
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        -- BEGIN_NVIM_THEME
        vim.o.background = "dark"
        vim.cmd.colorscheme("gentleman-kanagawa-blur")
        -- vim.o.background = "light"
        -- vim.cmd.colorscheme("gruvbox")
        -- END_NVIM_THEME
      end,
    },
  },
}
