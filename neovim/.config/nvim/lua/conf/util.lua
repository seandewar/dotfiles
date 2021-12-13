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

local function map(fn, mode, lhs, rhs, opts)
  opts = vim.tbl_extend("keep", opts or {}, { silent = true, noremap = true })
  mode = type(mode) ~= "table" and { mode } or mode
  lhs = type(lhs) ~= "table" and { lhs } or lhs

  for _, m in ipairs(mode) do
    for _, l in ipairs(lhs) do
      fn(m, l, rhs, opts)
    end
  end
end

--- defines a global key mapping via nvim_set_keymap.
--- defaults to a silent, non-recursive mapping
---@note mode and lhs can be a table
function M.map(...)
  map(api.nvim_set_keymap, ...)
end

--- like @{map}, but define a local mapping for the current buffer via
--- nvim_buf_set_keymap
function M.bmap(...)
  map(function(...)
    api.nvim_buf_set_keymap(0, ...)
  end, ...)
end

return M
