local get_identifier_at_cursor = require("idris2.utils.get_identifier_at_cursor")

local M = {}

---Handler for REPL responses with notify mode
function M.repl_handler__notify(err, result, _ctx, _config)
  if err ~= nil then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end
  vim.notify(result, vim.log.levels.INFO)
end

---Handler for REPL responses with notify and then ask for mode
---@param expr string Expression that was evaluated
---@param opts ReplOptions Additional options
---@return fun(err: string|nil, result: string|nil, ctx: table, config: table)
function M.repl_handler__notify_and_then_ask(expr, opts)
  return function(err, result, _ctx, _config)
    if err ~= nil then
      vim.notify(err, vim.log.levels.ERROR)
      return
    end

    vim.notify(result, vim.log.levels.INFO)

    local choices = { "substitute", "apply_virtual_comment" }
    vim.ui.select(choices, { prompt = 'Choose mode:' }, function(choice)
      if choice == "substitute" then
        local edit = { {
          range = {
            ['start'] = {
              line = opts.s_start[2] - 1,
              character = opts.s_start[3] - 1
            },
            ['end'] = {
              line = opts.s_end[2] - 1,
              character = opts.s_end[3]
            },
          },
          newText = result,
        } }
        vim.lsp.util.apply_text_edits(edit, vim.api.nvim_get_current_buf(), 'utf-32')
      elseif choice == "apply_virtual_comment" then
        local ns = vim.api.nvim_create_namespace('nvim-lsp-virtual-hl')
        vim.api.nvim_buf_set_extmark(
          opts.s_start[1],
          ns,
          opts.s_start[2] - 1,
          opts.s_start[3] - 1,
          {
            id = 1,
            virt_text = { { string.format('> %s => %s', expr, result), 'Comment' } },
            virt_text_pos = 'eol',
          }
        )
      else
        vim.notify("No valid mode selected", vim.log.levels.WARN)
      end
    end)
  end
end

---Get visual selection
---@return table|nil start_pos
---@return table|nil end_pos
---@return string|nil selected_text
local function get_visual_selection()
  local s_start = vim.fn.getpos("'<")
  local s_end = vim.fn.getpos("'>")
  local n_lines = math.abs(s_end[2] - s_start[2]) + 1
  local lines = vim.api.nvim_buf_get_lines(0, s_start[2] - 1, s_end[2], false)

  if vim.tbl_isempty(lines) then
    return nil, nil, nil
  end

  lines[1] = string.sub(lines[1], s_start[3], -1)
  if n_lines == 1 then
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3] - s_start[3] + 1)
  else
    lines[n_lines] = string.sub(lines[n_lines], 1, s_end[3])
  end
  return s_start, s_end, table.concat(lines, '\n')
end


function M.evaluate_visual()
  local s_start, s_end, sel = get_visual_selection()
  if not sel or sel == '' then
    vim.notify('Nothing is selected to evaluate', vim.log.levels.ERROR)
    return
  end
  local opts = { s_start = s_start, s_end = s_end }
  local params = {
    command = 'repl',
    arguments = { sel }
  }
  vim.lsp.buf_request(0, 'workspace/executeCommand', params, M.repl_handler__notify_and_then_ask(sel, opts))
end

---@param expr string Expression to evaluate
function M.evaluate_expr(expr)
  vim.validate({
    expr = { expr, 'string' },
  })
  if not expr or expr == '' then
    vim.notify('Nothing to evaluate', vim.log.levels.ERROR)
    return
  end

  local params = {
    command = 'repl',
    arguments = { expr },
  }
  vim.lsp.buf_request(0, 'workspace/executeCommand', params, M.repl_handler__notify)
end

function M.evaluate_input()
  vim.ui.input({ prompt = '> ', default = get_identifier_at_cursor() }, M.evaluate_expr)
end

return M
