-- *****************************************************************************
-- * Initialise la configuration de Neovim de l'environnement de développement *
-- *****************************************************************************

-- Options personnalisées
require("core.options")

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
