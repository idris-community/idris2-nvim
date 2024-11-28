local M = {}

function M.setup(bufnr)
  local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, {
      buffer = bufnr,
      noremap = true,
      silent = true,
      desc = desc
    })
  end
  -- Implicits
  map('n', '<leader>asi', ':IdrisShowImplicits<CR>', 'Show implicits')
  map('n', '<leader>ahi', ':IdrisHideImplicits<CR>', 'Hide implicits')

  -- Machine Names
  map('n', '<leader>asm', ':IdrisShowMachineNames<CR>', 'Show machine names')
  map('n', '<leader>ahm', ':IdrisHideMachineNames<CR>', 'Hide machine names')

  -- Namespace
  map('n', '<leader>asn', ':IdrisShowNamespace<CR>', 'Show full namespace')
  map('n', '<leader>ahn', ':IdrisHideNamespace<CR>', 'Hide namespace')

  -- Metavars
  map('n', '<leader>am?', ':IdrisMetavars<CR>', 'Show all metavariables')
  map('n', '<leader>amn', ':IdrisNextMetavar<CR>', 'Go to next metavariable')
  map('n', '<leader>amp', ':IdrisPrevMetavar<CR>', 'Go to previous metavariable')

  -- Evaluate
  map('v', '<leader>ae', require('idris2.repl').evaluate_visual,
    'Evaluate selected visual text and then ask to substitute or add virtual comments')

  -- map('v', '<leader>avs', function()
  --   require('idris2.repl').evaluate_visual("substitute")
  -- end, 'Evaluate selected visual text using substitute mode')

  -- map('n', '<leader>avv', function()
  --   require('idris2.repl').evaluate_visual("apply_virtual_comment")
  -- end, 'Evaluate input from prompt using apply_virtual_comment mode')

  -- map('v', '<leader>avn', function()
  --   require('idris2.repl').evaluate_visual("notify")
  -- end, 'Evaluate input from prompt using notify mode')

  map('n', '<leader>ab', ':IdrisBrowseNamespace<CR>', 'Browse namespace and jump')

  map('n', '<leader>aas', ':IdrisCaseSplit<CR>', 'Case split')
  map('n', '<leader>aac', ':IdrisMakeCase<CR>', 'Make case')
  map('n', '<leader>aaw', ':IdrisMakeWith<CR>', 'Make with')
  map('n', '<leader>aal', ':IdrisMakeLemma<CR>', 'Make lemma')
  map('n', '<leader>aaa', ':IdrisAddClause<CR>', 'Add clause')
  map('n', '<leader>aai', ':IdrisIntro<CR>', 'Intro')
  map('n', '<leader>aar', ':IdrisRefineHole<CR>', 'Refine hole')
  map('n', '<leader>aad', ':IdrisGenerateDef<CR>', 'Generate def')
  map('n', '<leader>aae', ':IdrisExprSearch<CR>', 'Expr search')
  map('n', '<leader>aah', ':IdrisExprSearchHints<CR>', 'Expr search with hints')
end

return M
