return {
	"github/copilot.vim",
	opts = {},
	config = function()
		vim.g.copilot_no_tab_map = false
		-- Don't annoy me, you're the CO-pilot remember?
		vim.api.nvim_set_keymap("i", "<C-y>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
	end,
}
