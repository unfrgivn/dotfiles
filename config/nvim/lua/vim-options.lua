vim.opt.expandtab = true
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.diagnostic.config({
	virtual_text = true, -- Enable virtual text
})

local keymap = vim.api.nvim_set_keymap
local default_opts = { noremap = true, silent = true }

keymap("n", "<C-h>", "<C-w>h", default_opts)
keymap("n", "<C-l>", "<C-w>l", default_opts)
keymap("n", "<C-j>", "<C-w>j", default_opts)
keymap("n", "<C-k>", "<C-w>k", default_opts)

-- Switch buffer, skipping special buffers (neo-tree, terminals, quickfix, etc.)
local function cycle_buffer(direction)
	local start = vim.api.nvim_get_current_buf()
	local cmd = direction == "next" and "bnext" or "bprevious"
	vim.cmd(cmd)
	while vim.bo.buftype ~= "" and vim.api.nvim_get_current_buf() ~= start do
		vim.cmd(cmd)
	end
end
vim.keymap.set("n", "<S-h>", function()
	cycle_buffer("prev")
end, { noremap = true, silent = true })
vim.keymap.set("n", "<S-l>", function()
	cycle_buffer("next")
end, { noremap = true, silent = true })

keymap("n", "<ESC>", ":nohlsearch<Bar>:echo<CR>", default_opts)

keymap("n", "jk", "<ESC>", default_opts)

vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"
