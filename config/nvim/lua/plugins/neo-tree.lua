return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MunifTanjim/nui.nvim",
		"nvim-tree/nvim-web-devicons",
	},
	lazy = false,
	config = function()
		require("neo-tree").setup({
			close_if_last_window = true,
			open_files_do_not_replace_types = {
				"terminal",
				"Trouble",
				"trouble",
				"qf",
				"edgy",
				"help",
				"noice",
				"notify",
			},
			auto_clean_after_session_restore = true,
			filesystem = {
				follow_current_file = {
					enabled = true,
				},
			},
		})

		vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left<CR>", { silent = true })
	end,
}
