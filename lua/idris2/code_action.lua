local M = {}

M.filters = {
  CASE_SPLIT = 'refactor.rewrite.CaseSplit',
  MAKE_CASE = 'refactor.rewrite.MakeCase',
  MAKE_WITH = 'refactor.rewrite.MakeWith',
  MAKE_LEMMA = 'refactor.extract.MakeLemma',
  ADD_CLAUSE = 'refactor.rewrite.AddClause',
  EXPR_SEARCH = 'refactor.rewrite.ExprSearch',
  GEN_DEF = 'refactor.rewrite.GenerateDef',
  REF_HOLE = 'refactor.rewrite.RefineHole',
  INTRO = 'refactor.rewrite.Intro',
}

-- function M.introspect_filter(action)
--   if string.match(action.title, "Case split") then
--     return M.filters.CASE_SPLIT
--   elseif string.match(action.title, "Make case") then
--     return M.filters.MAKE_CASE
--   elseif string.match(action.title, "Make with") then
--     return M.filters.MAKE_WITH
--   elseif string.match(action.title, "Add clause") then
--     return M.filters.ADD_CLAUSE
--   elseif string.match(action.title, "Make lemma") then
--     return M.filters.MAKE_LEMMA
--   elseif string.match(action.title, "Add clause") then
--     return M.filters.ADD_CLAUSE
--   elseif string.match(action.title, "Expression search") then
--     return M.filters.EXPR_SEARCH
--   elseif string.match(action.title, "Generate definition") then
--     return M.filters.GEN_DEF
--   elseif string.match(action.title, "Refine hole") then
--     return M.filters.REF_HOLE
--   elseif string.match(action.title, "Intro") then
--     return M.filters.INTRO
--   end
-- end

local function on_results(err, results, _ctx, _config)
  print(vim.inspect({ err, results }))
  if err ~= nil then
    vim.notify(err.message, vim.log.levels.ERROR)
    return
  end

  if not results or #results == 0 then
    vim.notify('No code actions available', vim.log.levels.INFO)
    return
  end

  local function apply_action(action)
    print(vim.inspect(action))
    if not action then
      return
    end
    vim.lsp.util.apply_workspace_edit(action.edit, 'utf-32')
  end

  if #results == 1 then
    apply_action(results[1])
  else
    vim.ui.select(results, {
      prompt = 'Code actions:',
      format_item = function(result)
        local title = result.title:gsub('\r\n', '\\r\\n')
        return title:gsub('\n', '\\n')
      end,
    }, apply_action)
  end
end

function M.request_single(filter)
  local params = vim.lsp.util.make_range_params()
  params['context'] = { diagnostics = {}, only = { filter } }
  vim.lsp.buf_request(0, 'textDocument/codeAction', params, on_results)
end

function M.case_split() M.request_single(M.filters.CASE_SPLIT) end

function M.make_case() M.request_single(M.filters.MAKE_CASE) end

function M.make_with() M.request_single(M.filters.MAKE_WITH) end

function M.make_lemma() M.request_single(M.filters.MAKE_LEMMA) end

function M.add_clause() M.request_single(M.filters.ADD_CLAUSE) end

function M.expr_search() M.request_single(M.filters.EXPR_SEARCH) end

function M.generate_def() M.request_single(M.filters.GEN_DEF) end

function M.intro() M.request_single(M.filters.INTRO) end

function M.refine_hole()
  local range = vim.lsp.util.make_range_params()
  vim.ui.input({
    prompt = 'Refine hole using: ',
    default_value = '',
  }, function(value)
    range.context = { diagnostics = {} }
    local params = {
      command = 'refineHole',
      arguments = { {
        codeAction = range,
        hint = value,
      } },
    }
    vim.lsp.buf_request(0, 'workspace/executeCommand', params, on_results)
  end)
end

function M.expr_search_hints()
  local range = vim.lsp.util.make_range_params()
  vim.ui.input(
    {
      prompt = 'Search hints using: ',
      default_value = ''
    },
    function(value)
      local hints = vim.split(value, ',')
      range.context = { diagnostics = {} }
      local params = {
        command = 'exprSearchWithHints',
        arguments = { {
          codeAction = range,
          hints = hints,
        } },
      }
      vim.lsp.buf_request(0, 'workspace/executeCommand', params, on_results)
    end
  )
end

return M
