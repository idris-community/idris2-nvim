local get_identifier_at_cursor = require("idris2.utils.get_identifier_at_cursor")
local M = {}

-- LSP Execute Command Request Options
function M.menu_handler(ns)
  return function(err, result, _ctx, _config)
    if err ~= nil then
      vim.notify(err, vim.log.levels.ERROR)
      return
    end

    if vim.tbl_isempty(result) then
      vim.notify('No definitions in ' .. ns, vim.log.levels.INFO)
      return
    end

    local items = vim.tbl_map(function(x)
      local details = ''
      if x.location ~= nil then
        details = '(' ..
            x.location.uri .. ':' .. x.location.range.start.line .. ',' .. x.location.range.start.character .. ')'
      end
      return {
        value = x.name,
        text = x.name .. details,
        entry = x
      }
    end, result)

    vim.ui.select(items, {
      prompt = 'Browse Namespace: ' .. ns,
      format_item = function(item)
        return item.text
      end
    }, function(item)
      if item then
        if item.entry.location ~= nil then
          vim.lsp.util.jump_to_location(item.entry.location, 'utf-32')
        else
          vim.notify('Selected name is not in a physical location', vim.log.levels.ERROR)
        end
      end
    end)
  end
end

-- TODO: get list of all available imports
function M.browse()
  vim.ui.input({
    prompt = 'Browse Namespace: ',
    default = get_identifier_at_cursor()
  }, function(value)
    if value then
      local params = {
        command = 'browseNamespace',
        arguments = { value },
      }
      vim.lsp.buf_request(0, 'workspace/executeCommand', params, M.menu_handler(value))
    end
  end)
end

return M
