local api = vim.api
local keymap = vim.keymap

local M = {}

--- replaces termcodes in a string
function M.t(str)
  return api.nvim_replace_termcodes(str, true, true, true)
end

function M.echo(msg)
  api.nvim_echo({ msg }, false, {})
end

function M.bmap(buf, mode, lhs, rhs, desc)
  keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
end

function M.bunmap(buf, mode, lhs)
  keymap.del(mode, lhs, { buffer = buf })
end

return M
