local fn = vim.fn

-- General Plugin Settings {{{1
-- nvim-treesitter {{{2
vim.cmd [[packadd nvim-treesitter]]
vim.cmd [[packadd nvim-treesitter-textobjects]]

require 'nvim-treesitter.configs'.setup {
  ensure_installed = 'maintained',

  -- these parsers require tree-sitter CLI, which may not be installed
  -- TODO: remove extra Windows-only ignores when they're fixed upstream
  ignore_install = vim.list_extend({
    'erlang', 'ocamllex', 'gdscript', 'devicetree', 'ledger', 'supercollider',
     'nix'
  }, (function()
    return fn.has('win32') == 1 and {'ocaml', 'ocaml_interface', 'typescript'}
                                 or {}
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
