local M = {}

local function pos_lt(x, y)
  if x.line == y.line then
    return x.character < y.character
  end
  return x.line < y.line
end

local function pos_gt(x, y)
  if x.line == y.line then
    return x.character > y.character
  end
  return x.line > y.line
end

function M.jump_handler(backward)
  local sorting = pos_lt
  local compare = pos_gt
  if backward then
    sorting = pos_gt
    compare = pos_lt
  end

  return function(err, result, _ctx, _config)
    if err ~= nil then
      vim.notify(err, vim.log.levels.ERROR)
      return
    end
    if vim.tbl_isempty(result) then
      vim.notify('No metavariables in context', vim.log.levels.INFO)
      return
    end

    -- Jump only within buffer
    local uri = vim.uri_from_bufnr(0)
    vim.tbl_filter(function(item)
      return item.uri == uri
    end, result)

    table.sort(result, function(x, y)
      return sorting(x.location.range.start, y.location.range.start)
    end)

    local curpos = vim.fn.getcurpos()
    local curloc = { line = curpos[2] - 1, character = curpos[3] - 1 }

    for _, v in ipairs(result) do
      if compare(v.location.range.start, curloc) then
        vim.lsp.util.jump_to_location(v.location, 'utf-32')
        return
      end
    end
    vim.lsp.util.jump_to_location(result[1].location, 'utf-32')
  end
end

function M.menu_handler(err, result, ctx, config)
  if err ~= nil then
    vim.notify(err, vim.log.levels.ERROR)
    return
  end

  if vim.tbl_isempty(result) then
    vim.notify('No metavariables in context', vim.log.levels.INFO)
    return
  end
  print(vim.inspect(result))
  vim.ui.select(result, {
    prompt = 'Select a metavariable',
    format_item = function(x)
      return x.name .. ' : ' .. x.type
    end,
  }, function(sel)
    print(vim.inspect(sel))
    if sel ~= nil and sel.location ~= nil then
      vim.lsp.util.jump_to_location(sel.location, 'utf-32')
    else
      vim.notify('Selected metavar is not in a physical location', vim.log.levels.ERROR)
    end
  end)
end

function M.request_all()
  vim.lsp.buf_request(0, 'workspace/executeCommand', { command = 'metavars' }, M.menu_handler)
end

function M.goto_next()
  vim.lsp.buf_request(0, 'workspace/executeCommand', { command = 'metavars' }, M.jump_handler(false))
end

function M.goto_prev()
  vim.lsp.buf_request(0, 'workspace/executeCommand', { command = 'metavars' }, M.jump_handler(true))
end

return M
