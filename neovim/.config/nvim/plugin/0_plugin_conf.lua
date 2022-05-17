local api = vim.api

-- TODO: Nvim doesn't yet support passing containers by reference via the
-- bridge, so we need this wrapper function to update the components dictionary.
vim.cmd [[
  function! ConfDefineStatusLineComponent(name, fn) abort
      let g:conf_statusline_components[a:name] = a:fn
  endfunction
]]

require "conf.diagnostic"
require "conf.treesitter"
require "conf.telescope"
require "conf.lsp"
require "conf.firenvim"
