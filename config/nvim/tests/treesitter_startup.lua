-- Run with: nvim --headless --cmd 'set noswapfile' --cmd 'let g:treesitter_auto_install = v:false' '+luafile tests/treesitter_startup.lua'
local ok, err = pcall(function()
	local messages = vim.api.nvim_exec2("messages", { output = true }).output
	assert(not messages:find("Failed to run `config` for nvim-treesitter", 1, true), messages)
	vim.cmd.edit("init.lua")
	local buf = vim.api.nvim_get_current_buf()
	assert(vim.treesitter.highlighter.active[buf], "Lua Treesitter highlighting is not active")
	assert(vim.bo[buf].indentexpr == "v:lua.require'nvim-treesitter'.indentexpr()")
end)

if not ok then
	print(err)
	vim.cmd.cquit(1)
end
print("Treesitter startup and Lua highlighting OK")
vim.cmd("qa!")
