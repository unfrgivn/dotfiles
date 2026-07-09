return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<C-p>", function()
				builtin.find_files({ hidden = true })
			end, { desc = "Find files" })
			vim.keymap.set("n", "<leader>tg", builtin.live_grep, { desc = "Telescope live grep" })
			vim.keymap.set("n", "<leader>tf", function()
				local ok = pcall(builtin.git_files)
				if not ok then
					builtin.find_files({ hidden = true })
				end
			end, { desc = "Telescope git files" })
		end,
	},
	{
		"nvim-telescope/telescope-ui-select.nvim",
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown({}),
					},
				},
			})
			require("telescope").load_extension("ui-select")
		end,
	},
}
