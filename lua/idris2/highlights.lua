local M = {}

function M.setup()
  vim.api.nvim_set_hl(0, '@lsp.type.type', { fg = '#8be9fd' })                      -- Cyan
  vim.api.nvim_set_hl(0, '@lsp.type.function', { fg = '#ff79c6' })                  -- Pink
  vim.api.nvim_set_hl(0, '@lsp.type.enumMember', { italic = true })                 -- Purple
  vim.api.nvim_set_hl(0, '@lsp.type.variable', { fg = '#ffb86c', bg = '#282828' })  -- Orange
  vim.api.nvim_set_hl(0, '@lsp.type.keyword', { fg = '#bd93f9', bold = true })      -- Red
  vim.api.nvim_set_hl(0, '@lsp.type.namespace', { fg = '#50fa7b', italic = true })  -- Green
  vim.api.nvim_set_hl(0, '@lsp.type.postulate', { fg = '#ffffff', bg = '#ff5555' }) -- Red
  vim.api.nvim_set_hl(0, '@lsp.type.module', { fg = '#f1fa8c' })                    -- Yellow
end

return M
