local api = vim.api

local M = {}

function M.echo(msg)
  msg = type(msg) == "string" and { { msg } } or msg
  api.nvim_echo(msg, false, {})
end

function M.echomsg(msg)
  msg = type(msg) == "string" and { { msg } } or msg
  api.nvim_echo(msg, true, {})
end

return M
