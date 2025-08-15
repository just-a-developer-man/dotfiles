return {
  {
    "ray-x/go.nvim",
    ft = {"go"},
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap",
    },
    config = function()
      require("go").setup({
        goimport = "goimports",  -- или "gofumpt"
        gofmt = "gofumpt",
        lsp_cfg = true,
        lsp_on_attach = function(client, bufnr)
          local opts = { noremap=true, silent=true, buffer=bufnr }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        end,
        dap_debug = true,
        linter = "revive",
      })
    end,
  },
}
