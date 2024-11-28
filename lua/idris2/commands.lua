local M = {}

local function toggle_setting(setting_name, bufnr, target_value)
  return function()
    local settings = { [setting_name] = target_value }
    vim.lsp.buf_notify(bufnr, "workspace/didChangeConfiguration", { settings = settings })
    vim.notify("Toggled " .. setting_name .. " to " .. (target_value and "shown" or "hidden"))

    -- TODO: workspace/configuration Error: Method not implemented yet
    -- local params = { items = { scopeUri = vim.api.nvim_buf_get_name(bufnr), section = 'settings' } }
    -- vim.lsp.buf_request(bufnr, 'workspace/configuration', params, function(error, result)
    --   if error then
    --     vim.notify("Error: " .. error.message)
    --     return
    --   end

    --   if not result then
    --     vim.notify("No current configuration found.")
    --     return
    --   end

    --   local settings = result.settings

    --   if settings[setting_name] == target_value then
    --     vim.notify(setting_name .. " are already " .. (target_value and "shown" or "hidden") .. ".")
    --   else
    --     vim.lsp.buf_notify(bufnr, "workspace/didChangeConfiguration", { settings = { [setting_name] = target_value } })
    --   end
    -- end)
  end
end

function M.setup(bufnr)
  ---Create a buffer-local command
  ---@param name string Command name
  ---@param fn function Command function
  ---@param opts string|table Command description or options
  ---@return function Command creation function that takes buffer number
  local function create_command(name, fn, opts)
    local options = type(opts) == "table" and opts or { desc = tostring(opts) }
    vim.api.nvim_buf_create_user_command(bufnr, name, fn, options)
  end

  -- Toggle commands
  create_command('IdrisShowImplicits', toggle_setting('showImplicits', bufnr, true), "Show Idris implicits")
  create_command('IdrisHideImplicits', toggle_setting('showImplicits', bufnr, false), "Hide Idris implicits")
  create_command('IdrisShowMachineNames', toggle_setting('showMachineNames', bufnr, true), "Show Idris machine names")
  create_command('IdrisHideMachineNames', toggle_setting('showMachineNames', bufnr, false), "Hide Idris machine names")
  create_command('IdrisShowNamespace', toggle_setting('fullNamespace', bufnr, true), "Show full namespace")
  create_command('IdrisHideNamespace', toggle_setting('fullNamespace', bufnr, false), "Hide namespace")

  -- Metavars commands
  create_command('IdrisMetavars', require('idris2.metavars').request_all, "Show all metavariables")
  create_command('IdrisNextMetavar', require('idris2.metavars').goto_next, "Go to next metavariable")
  create_command('IdrisPrevMetavar', require('idris2.metavars').goto_prev, "Go to previous metavariable")

  -- Evaluate commands
  create_command('IdrisEvaluateExpr', function(args)
    local expr = table.concat(args.fargs, " ")
    require('idris2.repl').evaluate_expr(expr)
  end, { desc = "Evaluate an expression", nargs = "+" })
  create_command('IdrisEvaluateInput', require('idris2.repl').evaluate_input, "Evaluate input from prompt")
  create_command('IdrisEvaluateVisual', require('idris2.repl').evaluate_visual, "Evaluate selected visual text")

  -- Browse commands
  create_command('IdrisBrowseNamespace', require('idris2.browse').browse, "Browse namespace and jump")

  -- Code actions
  create_command('IdrisCaseSplit', require('idris2.code_action').case_split, "Case split")
  create_command('IdrisMakeCase', require('idris2.code_action').make_case, "Make case")
  create_command('IdrisMakeWith', require('idris2.code_action').make_with, "Make with")
  create_command('IdrisMakeLemma', require('idris2.code_action').make_lemma, "Make lemma")
  create_command('IdrisAddClause', require('idris2.code_action').add_clause, "Add clause")
  create_command('IdrisExprSearch', require('idris2.code_action').expr_search, "Expr search")
  create_command('IdrisGenerateDef', require('idris2.code_action').generate_def, "Generate def")
  create_command('IdrisIntro', require('idris2.code_action').intro, "Intro")
  create_command('IdrisRefineHole', require('idris2.code_action').refine_hole, "Refine hole")
  create_command('IdrisExprSearchHints', require('idris2.code_action').expr_search_hints, "Expr search with hints")
end

return M
