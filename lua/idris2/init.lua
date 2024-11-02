local M = {}

function M.setup__root_dir_or_error(startpath)
  local path = require("lspconfig").util.root_pattern("*.ipkg")(startpath)
  if path ~= nil then
    return path
  end

  vim.notify(
    string.format(
      "[idris2_lsp] could not find an .ipkg file in %s or any parent directory.\n" ..
      "Hint: use 'idris2 --init' or 'pack new' to intialize an Idris2 project.",
      startpath
    ),
    vim.log.levels.WARN
  )
end

function M.setup__on_attach(_client, bufnr)
  require('idris2.highlights').setup()
  require('idris2.commands').setup(bufnr)
  require('idris2.keymaps').setup(bufnr)
end

return M
