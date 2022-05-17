local api = vim.api

local M = {}

--- replaces termcodes in a string
function M.t(str)
  return api.nvim_replace_termcodes(str, true, true, true)
end

function M.echo(msg)
  api.nvim_echo({ msg }, false, {})
end

return M
