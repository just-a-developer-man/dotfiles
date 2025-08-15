return {
	"ray-x/go.nvim",
	ft = "go",
	dependencies = {
		"ray-x/guihua.lua",
		"neovim/nvim-lspconfig",
		"nvim-treesitter/nvim-treesitter",
	},
	config = function()
		require("go").setup({ lsp_cfg = true, lsp_gofumpt = true })
	end,
}
