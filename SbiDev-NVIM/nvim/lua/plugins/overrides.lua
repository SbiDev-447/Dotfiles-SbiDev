-- This file contains the configuration overrides for specific Neovim plugins.

return {
  {
    "mason-org/mason.nvim",
    opts = {
      automatic_installation = {
        exclude = {
          "markdown-toc",
        },
      },
    },
  },

  -- Disable markdown formatters
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        -- Disable markdown formatting (the markdown extra enables prettier/markdownlint-cli2/markdown-toc).
        markdown = {},
        ["markdown.mdx"] = {},
      },
    },
  },

  -- Remove inlay hints from default configuration
  {
    -- Plugin: nvim-lspconfig
    -- URL: https://github.com/neovim/nvim-lspconfig
    -- Description: Quickstart configurations for the Neovim LSP client.
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false }, -- Disable inlay hints
      servers = {
        angularls = {
          -- Configuration for Angular Language Server
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern("angular.json", "project.json")(fname)
          end,
        },
        nil_ls = {
          -- Configuration for nil (Nix Language Server), already installed via nix
          cmd = { "nil" },
          autostart = true,
          mason = false, -- Explicitly disable mason management for nil_ls
          settings = {
            ["nil"] = {
              formatting = { command = { "nixpkgs-fmt" } },
            },
          },
        },
      },
    },
  },
}
