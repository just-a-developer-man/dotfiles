return {
	{
		"folke/tokyonight.nvim",
		opts = function()
			return { transparent = true, style = "night", styles = { sidebars = "transparent", floats = "transparent" } }
		end,
	},
	{
		"williamboman/mason.nvim",
		commit = "4da89f3",
	},
	{
		"williamboman/mason-lspconfig.nvim",
		commit = "1a31f82",
		dependencies = { "mason.nvim" },
		config = function()
			local lspconfig = require("lspconfig")
			local mason_lsp = require("mason-lspconfig")

			mason_lsp.setup({
				ensure_installed = { "gopls", "pyright", "yamlls", "jsonls", "buf_ls", "ts_ls" },
			})

			mason_lsp.setup_handlers({
				function(server_name)
					lspconfig[server_name].setup({})
				end,
			})
		end,
	},

	-- ==========================
	-- Autocompletion
	-- ==========================
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = { "hrsh7th/cmp-nvim-lsp", "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip" },
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
				},
			})
		end,
	},

	-- ==========================
	-- Go.nvim
	-- ==========================
	{
		"ray-x/go.nvim",
		dependencies = { -- optional packages
			"ray-x/guihua.lua",
			"neovim/nvim-lspconfig",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {
			-- lsp_keymaps = false,
			-- other options
		},
		config = function(lp, opts)
			require("go").setup(opts)
			local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
			vim.api.nvim_create_autocmd("BufWritePre", {
				pattern = "*.go",
				callback = function()
					require("go.format").goimports()
				end,
				group = format_sync_grp,
			})
		end,
		event = { "CmdlineEnter" },
		ft = { "go", "gomod" },
		build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
	},

	{ "iamcco/markdown-preview.nvim", build = "cd app && npm install", ft = { "markdown" } },

	{
		"echasnovski/mini.surround",
		config = function()
			require("mini.surround").setup()
		end,
	},
}
