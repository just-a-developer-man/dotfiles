return {
	{
		"folke/tokyonight.nvim",
		opts = function()
			return { transparent = true, style = "night", styles = { sidebars = "transparent", floats = "transparent" } }
		end,
	},
	{ "williamboman/mason.nvim", commit = "4da89f3" },
	{ "williamboman/mason-lspconfig.nvim", commit = "1a31f82" },
	{ "iamcco/markdown-preview.nvim", build = "cd app && npm install", ft = { "markdown" } },
	{
		"echasnovski/mini.surround",
		config = function()
			require("mini.surround").setup()
		end,
	},
	{
		"jose-elias-alvarez/null-ls.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			require("null-ls").setup({
				sources = {
					require("null-ls").builtins.formatting.gofumpt,
					require("null-ls").builtins.diagnostics.golangci_lint,
					require("null-ls").builtins.formatting.goimports,
				},
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		config = function()
			local lspconfig = require("lspconfig")
			for _, lsp in ipairs({ "pyright", "yamlls", "jsonls", "bufls" }) do
				lspconfig[lsp].setup({})
			end
		end,
	},
	{ "hrsh7th/nvim-cmp", dependencies = { "hrsh7th/cmp-nvim-lsp", "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip" } },
}
