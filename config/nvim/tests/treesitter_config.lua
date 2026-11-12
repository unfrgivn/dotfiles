-- Run with: nvim --headless -u NONE '+luafile tests/treesitter_config.lua'
local ok, err = pcall(function()
	local installed, selected
	package.loaded["nvim-treesitter"] = {
		setup = function() end,
		install = function(languages) installed = languages end,
		get_available = function() return {
			"bash", "css", "diff", "javascript", "lua", "markdown", "ninja", "python", "rst", "sql",
			"terraform", "tmux", "tsx", "typescript", "yaml",
		} end,
	}
	local executable = vim.fn.executable
	vim.fn.executable = function() return 1 end
	local add = vim.treesitter.language.add
	vim.treesitter.language.add = function(lang, opts)
		if lang == "lua" then selected = opts.path end
	end
	local runtime_files = vim.api.nvim_get_runtime_file
	vim.api.nvim_get_runtime_file = function(name, all)
		if name == "parser/lua.*" then return { "/arbitrary/parser/lua.so" } end
		return runtime_files(name, all)
	end
	dofile("lua/plugins/treesitter.lua").config()
	vim.fn.executable = executable
	vim.treesitter.language.add = add
	assert(selected and selected ~= "/arbitrary/parser/lua.so", "bundled Lua parser was not selected")
	local prefix = vim.fn.fnamemodify(vim.env.VIMRUNTIME, ":h:h:h")
	assert(selected:find(vim.env.VIMRUNTIME .. "/parser/", 1, true) == 1
		or selected:find(prefix .. "/lib/nvim/parser/", 1, true) == 1, selected)
	assert(vim.fn.filereadable(selected) == 1, selected)
	assert(vim.deep_equal(installed, {
		"bash", "css", "diff", "javascript", "lua", "markdown", "ninja", "python", "rst", "sql",
		"terraform", "tmux", "tsx", "typescript", "yaml",
	}), "configured parsers were not scheduled for installation")
end)
if not ok then
	print(err)
	vim.cmd.cquit(1)
end
print("Treesitter configuration OK")
vim.cmd("qa!")
