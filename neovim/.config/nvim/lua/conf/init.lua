-- TODO: Nvim doesn't yet support passing container types by reference via the
-- Vimscript -> Lua bridge, so we need this wrapper function to update the
-- components dictionary.
vim.cmd [[
  function! ConfDefineStatusLineComponent(name, fn) abort
      let g:conf_statusline_components[a:name] = a:fn
  endfunction
]]

require "conf.diagnostic"
require "conf.treesitter"
require "conf.lsp"
require "conf.telescope"
