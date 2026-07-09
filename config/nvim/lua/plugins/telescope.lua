return {
	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.8",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			local builtin = require("telescope.builtin")
			local find_files = function()
				builtin.find_files({
					find_command = {
						"sh",
						"-c",
						[[(rg --files --hidden --glob '!.git/*'; rg --files --hidden --no-ignore --glob '**/.env*' --glob '!.git/*') | sort -u]],
					},
				})
			end

			vim.keymap.set("n", "<C-p>", function()
				find_files()
			end, { desc = "Find files" })
			vim.keymap.set("n", "<leader>tg", builtin.live_grep, { desc = "Telescope live grep" })
			vim.keymap.set("n", "<leader>tf", function()
				local ok = pcall(builtin.git_files)
				if not ok then
					find_files()
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
