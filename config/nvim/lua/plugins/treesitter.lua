return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local treesitter = require("nvim-treesitter")
		treesitter.setup()
		local parsers = {
			"bash", "css", "diff", "javascript", "lua", "markdown", "ninja", "python", "rst", "sql",
			"terraform", "tmux", "tsx", "typescript", "yaml",
		}
		local auto_install = vim.g.treesitter_auto_install ~= false
		if auto_install and vim.fn.executable("tree-sitter") == 0 then
			auto_install = false
			vim.notify("Treesitter auto-install requires the tree-sitter CLI on PATH", vim.log.levels.WARN)
		end
		if auto_install then
			local available = treesitter.get_available()
			local supported = vim.tbl_filter(function(lang) return vim.list_contains(available, lang) end, parsers)
			treesitter.install(supported)
		end
		local requested = {}
		for _, lang in ipairs(parsers) do
			requested[lang] = true
		end

		-- Neovim's bundled Lua query requires its matching bundled parser.
		local runtime = vim.env.VIMRUNTIME
		local prefix = vim.fn.fnamemodify(runtime, ":h:h:h")
		for _, dir in ipairs({ runtime .. "/parser", prefix .. "/lib/nvim/parser" }) do
			local bundled = vim.fn.glob(dir .. "/lua.*", false, true)
			if #bundled == 1 and vim.fn.filereadable(bundled[1]) == 1 then
				vim.treesitter.language.add("lua", { path = bundled[1] })
				break
			end
		end

		vim.api.nvim_create_autocmd("FileType", {
			callback = function(args)
				if pcall(vim.treesitter.start, args.buf) then
					vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				elseif auto_install then
					local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
					if lang and not requested[lang] and vim.list_contains(treesitter.get_available(), lang) then
						local ok, loaded = pcall(vim.treesitter.language.add, lang)
						if not ok or not loaded then
							requested[lang] = true
							treesitter.install({ lang })
						end
					end
				end
			end,
		})
	end,
}
