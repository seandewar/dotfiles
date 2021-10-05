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

--- defines a global key mapping via nvim_set_keymap.
--- defaults to a silent, non-recursive mapping
function M.map(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("keep", opts or {}, { silent = true, noremap = true })
  api.nvim_set_keymap(mode, lhs, rhs, opts)
end

--- like @{map}, but define a local mapping for the current buffer via
--- nvim_buf_set_keymap
function M.bmap(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("keep", opts or {}, { silent = true, noremap = true })
  api.nvim_buf_set_keymap(0, mode, lhs, rhs, opts)
end

return M
