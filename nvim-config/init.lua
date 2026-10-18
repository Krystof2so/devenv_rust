-- *****************************************************************************
-- * Initialise la configuration de Neovim de l'environnement de développement *
-- *****************************************************************************

-- Options personnalisées
require("core.options")
require("core.folding").setup()

-- Plugins
vim.pack.add({
	"https://github.com/catppuccin/nvim",           -- thème
    "https://github.com/nvimdev/dashboard-nvim",    -- page d'accueil
})

-- Thème
vim.cmd.colorscheme("catppuccin-macchiato")

-- Page d'accueil (dashboard-nvim) — visible quand on lance simplement 'nvrust'
require("dashboard").setup({
	theme = "hyper",
	hide = { statusline = true, tabline = true, winbar = true },
	config = {
		week_header = { enable = false }, -- désactive l'en-tête date/heure par défaut
		header = { "", "🦀  Rust & devenv", "" },
		shortcut = {
			{ icon = "  ", desc = "Explorateur", key = "e", action = "Lexplore" },
			{ icon = "  ", desc = "Quitter", key = "q", action = "quit" },
		},
		packages = { enable = false }, -- masque la section des plugins
		project = { enable = false }, -- masque la section des projets
		mru = {
			enable = true,
			limit = 10, -- nombre de fichiers affichés
			label = "Fichiers récents",
			cwd_only = false, -- true : uniquement les fichiers du répertoire courant
		},
		footer = {},
	},
})

-- LSP 'Rust'
vim.lsp.enable("rust_analyzer")

-- Diagnostics (rust-analyzer, clippy) : message en bout de ligne
vim.diagnostic.config({
	virtual_text = true,
	severity_sort = true,
})

-- Complétion LSP intégrée : le menu s'ouvre en tapant des lettres, pas seulement après . et ::
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client or not client:supports_method("textDocument/completion") then
			return
		end

		-- Ajouter les lettres aux caractères déclencheurs annoncés par le serveur
		local provider = client.server_capabilities.completionProvider
		if provider then
			local chars, seen = {}, {}
			for _, c in ipairs(provider.triggerCharacters or {}) do
				chars[#chars + 1], seen[c] = c, true
			end
			for c in ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"):gmatch(".") do
				if not seen[c] then
					chars[#chars + 1] = c
				end
			end
			provider.triggerCharacters = chars
		end

		vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
	end,
})
