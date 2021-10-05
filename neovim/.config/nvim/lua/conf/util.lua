local api = vim.api

local M = {}

function M.reload()
  for module, _ in pairs(package.loaded) do
    local capture = module:match "^conf(.*)$"
    if capture and (capture == "" or capture:match "%..+") then
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
