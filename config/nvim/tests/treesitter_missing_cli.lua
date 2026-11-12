-- Run with: nvim --headless -u NONE '+luafile tests/treesitter_missing_cli.lua'
local ok, err = pcall(function()
	assert(vim.fn.executable("tree-sitter") == 0, "test requires tree-sitter CLI to be absent")
	vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/nvim-treesitter")
	local notifications = {}
	vim.notify = function(message) table.insert(notifications, message) end
	dofile("lua/plugins/treesitter.lua").config()
	assert(vim.wait(1000, function() return #notifications > 0 end), "missing CLI was not reported")
	assert(table.concat(notifications):find("tree-sitter CLI", 1, true), vim.inspect(notifications))
	vim.bo.filetype = "python"
	vim.wait(1000)
	local messages = vim.api.nvim_exec2("messages", { output = true }).output
	assert(not messages:find("Downloading tree-sitter", 1, true), messages)
end)
if not ok then
	print(err)
	vim.cmd.cquit(1)
end
print("Missing Treesitter CLI handled")
vim.cmd("qa!")
