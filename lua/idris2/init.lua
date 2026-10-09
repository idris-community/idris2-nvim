local config = require("idris2.config")
local hover = require("idris2.hover")
local code_action = require("idris2.code_action")

local M = {}

local function setup_on_attach()
	local lsp_opts = config.options.server
	local user_on_attach = lsp_opts.on_attach -- Save user callback

	lsp_opts.on_attach = function(...)
		if user_on_attach ~= nil then
			user_on_attach(...) -- Call user callback
		end
	end
end

local function setup_capabilities()
	local lsp_opts = config.options.server
	local capabilities = vim.lsp.protocol.make_client_capabilities()

	capabilities["workspace"]["semanticTokens"] = { refreshSupport = true }
	capabilities["textDocument"]["hover"]["contentFormat"] = {}
	lsp_opts.capabilities = vim.tbl_deep_extend("force", capabilities, lsp_opts.capabilities or {})
end

local function setup_handlers()
	local lsp_opts = config.options.server
	local custom_handlers = {}

	lsp_opts.handlers = vim.tbl_deep_extend("force", custom_handlers, lsp_opts.handlers or {})
end

local function setup_lsp()
	local root_dir_error = function(bufnr, on_dir)
		local startpath = vim.api.nvim_buf_get_name(bufnr)
		local path = vim.fs.root(bufnr, function(name)
			return name:match("%.ipkg$") ~= nil
		end)
		if path == nil then
			vim.notify(
				string.format(
					"[idris2_lsp] could not find an .ipkg file in %s or any parent directory.\nHint: use 'idris2 --init' or 'pack new' to intialize an Idris2 project.",
					startpath
				),
				vim.log.levels.WARN
			)
		end
		on_dir(path)
	end
	local server = vim.tbl_deep_extend("force", config.options.server, { root_dir = root_dir_error })
	vim.lsp.config("idris2_lsp", server)
	vim.lsp.enable("idris2_lsp")
end

function M.setup(options)
	config.setup(options)

	setup_capabilities()
	setup_on_attach()
	setup_handlers()
	hover.setup()
	code_action.setup()

	if config.options.use_default_semantic_hl_groups then
		vim.cmd([[highlight link @lsp.type.variable.idris2 idrisString]])
		vim.cmd([[highlight link @lsp.type.enumMember.idris2 idrisStructure]])
		vim.cmd([[highlight link @lsp.type.function.idris2 idrisIdentifier]])
		vim.cmd([[highlight link @lsp.type.type.idris2 idrisType]])
		vim.cmd([[highlight link @lsp.type.keyword.idris2 idrisStatement]])
		vim.cmd([[highlight link @lsp.type.namespace.idris2 idrisImport]])
		vim.cmd([[highlight link @lsp.type.postulate.idris2 idrisStatement]])
		vim.cmd([[highlight link @lsp.type.module.idris2 idrisModule]])
	end

	vim.filetype.add{
		extension = {
		 idr = 'idris2'
		}
	}

	setup_lsp()
end

function M.show_implicits()
	vim.lsp.buf_notify(0, "workspace/didChangeConfiguration", { settings = { showImplicits = true } })
end

function M.hide_implicits()
	vim.lsp.buf_notify(0, "workspace/didChangeConfiguration", { settings = { showImplicits = false } })
end

function M.show_machine_names()
	vim.lsp.buf_notify(0, "workspace/didChangeConfiguration", { settings = { showMachineNames = true } })
end

function M.hide_machine_names()
	vim.lsp.buf_notify(0, "workspace/didChangeConfiguration", { settings = { showMachineNames = false } })
end

function M.full_namespace()
	vim.lsp.buf_notify(0, "workspace/didChangeConfiguration", { settings = { fullNamespace = true } })
end

function M.hide_namespace()
	vim.lsp.buf_notify(0, "workspace/didChangeConfiguration", { settings = { fullNamespace = false } })
end

function M.set_ipkg_path(path)
	vim.lsp.buf_notify(0, "workspace/didChangeConfiguration", { settings = { ipkgPath = path } })
end

function M.set_log_level(lvl)
	vim.lsp.buf_notify(0, "workspace/didChangeConfiguration", { settings = { logSeverity = lvl } })
end

function M.brief_completions()
	vim.lsp.buf_notify(0, "workspace/didChangeConfiguration", { settings = { briefCompletions = true } })
end

function M.full_completions()
	vim.lsp.buf_notify(0, "workspace/didChangeConfiguration", { settings = { briefCompletions = false } })
end

return M
