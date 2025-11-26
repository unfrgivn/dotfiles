return {
	"kdheepak/lazygit.nvim",
	cmd = {
		"LazyGit",
		"LazyGitConfig",
		"LazyGitCurrentFile",
		"LazyGitFilter",
		"LazyGitFilterCurrentFile",
	},
	-- optional for floating window border decoration
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	-- setting the keybinding for LazyGit with 'keys' is recommended in
	-- order to load the plugin when the command is run for the first time
	keys = {
		-- { "<leader>lg", "<cmd>LazyGit<cr>", desc = "Open lazy git" },
		{
			"<leader>lg",
			function()
				--  get file name with extension
				local file = vim.fn.expand("%:t")
				vim.cmd("LazyGit")

				-- Wait a bit for LazyGit to load
				vim.defer_fn(function()
					-- search for the file, highlight, and exit search mode in lazygit
					vim.api.nvim_feedkeys("/" .. file, "t", true)
					vim.api.nvim_input("<CR>")
					vim.api.nvim_input("<ESC>")
				end, 150) -- (milliseconds)
			end,
			{ desc = "[g]it" },
		},
	},
}
