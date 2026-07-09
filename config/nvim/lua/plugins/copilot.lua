return {
	"github/copilot.vim",
	opts = {},
	config = function()
		vim.g.copilot_no_tab_map = true
		-- Don't annoy me, you're the CO-pilot remember?
		vim.keymap.set(
			"i",
			"<M-CR>",
			'copilot#Accept("<CR>")',
			{ silent = true, expr = true, replace_keycodes = false }
		)
	end,
}
