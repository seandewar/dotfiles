local cmd = vim.cmd

-- TODO: Nvim doesn't yet support passing container types by reference via the
-- Vimscript -> Lua bridge, so we need this wrapper function to update the
-- components dictionary.
cmd [[
  function! ConfDefineStatusLineComponent(name, fn) abort
      let g:conf_statusline_components[a:name] = a:fn
  endfunction
]]

-- firenvim
if vim.g.started_by_firenvim then
  cmd "packadd firenvim"
  cmd "runtime ginit.vim"
end

-- Others
require "conf.diagnostic"
require "conf.treesitter"
require "conf.telescope"

if not vim.g.started_by_firenvim then
  require "conf.lsp"
end
