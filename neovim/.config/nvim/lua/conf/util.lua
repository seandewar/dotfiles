local api = vim.api

local M = {}

--- replaces termcodes in a string
function M.t(str)
  return api.nvim_replace_termcodes(str, true, true, true)
end

function M.echo(msg)
  msg = type(msg) == "string" and { { msg } } or msg
  api.nvim_echo(msg, false, {})
end

function M.echomsg(msg)
  msg = type(msg) == "string" and { { msg } } or msg
  api.nvim_echo(msg, true, {})
end

return M
