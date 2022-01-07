local api = vim.api

local M = {}

function M.reload()
  for module, _ in pairs(package.loaded) do
    local capture = module:match "^conf(.*)$"

    -- NOTE: do not reload the lsp modules as it'll cause lspconfig's setup()
    -- function to be called twice, which will define multiple FileType autocmds
    -- to start the servers that can cause issues (duplicate messages, etc.)
    if
      capture
      and (capture == "" or capture:match "%..+")
      and not capture:match "%.lsp"
    then
      package.loaded[module] = nil
    end
  end

  return require "conf"
end

--- replaces termcodes in a string
function M.t(str)
  return api.nvim_replace_termcodes(str, true, true, true)
end

return M
