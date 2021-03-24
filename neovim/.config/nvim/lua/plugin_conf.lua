--[[""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sean Dewar's Neovim 0.5+ Lua Plugin Config <https://github.com/seandewar>    "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""]]

-- File Locals {{{1
local api, fn = vim.api, vim.fn

-- General Plugin Settings {{{1
-- telescope.nvim {{{2
vim.cmd 'packadd telescope.nvim'
vim.cmd 'packadd plenary.nvim'
vim.cmd 'packadd popup.nvim'

-- nvim-treesitter {{{2
vim.cmd 'packadd nvim-treesitter'
vim.cmd 'packadd nvim-treesitter-textobjects'

require 'nvim-treesitter.configs'.setup {
  ensure_installed = 'maintained',

  -- these parsers require tree-sitter CLI, which may not be installed
  -- TODO: remove extra Windows-only ignores when they're fixed upstream
  ignore_install = vim.list_extend({
    'erlang', 'ocamllex', 'gdscript', 'devicetree', 'ledger', 'supercollider',
    'nix',
  }, (function()
    return fn.has('win32') == 1
      and {'ocaml', 'ocaml_interface', 'typescript', 'tsx'} or {}
  end)()),

  highlight = {
    enable = true,

    -- enable :syntax highlights so spell-checker ignores code
    -- TODO: we won't need this once TS is updated to do this
    additional_vim_regex_highlighting = true,
  },

  incremental_selection = {enable = true},
  -- indent = {enable = true}, -- NOTE: disabled due to bugs

  -- NOTE: these don't define mappings for us, so let's define them
  -- (see ':help nvim-treesitter-textobjects-mod')
  textobjects = {
    select = {
      enable = true,
      keymaps = {
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
  }
}

-- Mappings {{{1
-- telescope.nvim {{{2
api.nvim_set_keymap(
  'n', '<leader>fb', '<cmd>Telescope buffers<cr>', {silent = true})
api.nvim_set_keymap(
  'n', '<leader>ff', '<cmd>Telescope find_files<cr>', {silent = true})
api.nvim_set_keymap(
  'n', '<leader>fg', '<cmd>Telescope live_grep<cr>', {silent = true})
api.nvim_set_keymap(
  'n', '<leader>fo', '<cmd>Telescope oldfiles<cr>', {silent = true})

api.nvim_set_keymap(
  'n', '<leader>fc', '<cmd>Telescope quickfix<cr>', {silent = true})
api.nvim_set_keymap(
  'n', '<leader>fl', '<cmd>Telescope loclist<cr>', {silent = true})

api.nvim_set_keymap(
  'n', '<leader>ft', '<cmd>Telescope tags<cr>', {silent = true})
api.nvim_set_keymap(
  'n', '<leader>fs', '<cmd>Telescope treesitter<cr>', {silent = true})
