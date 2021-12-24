local cmd = vim.cmd
local api = vim.api
local fn = vim.fn
local diagnostic = vim.diagnostic

local map = require("conf.util").map

local M = {}

local virtual_text_ns = api.nvim_create_namespace "conf_diagnostic_virtual_text"

-- Display virtual text for the current line only
function M.update_virtual_text()
  if api.nvim_get_mode().mode:match "i" then
    return
  end
  local buf = api.nvim_get_current_buf()
  local row = api.nvim_win_get_cursor(0)[1]
  local line_diags = diagnostic.get(buf, { lnum = row - 1 })
  diagnostic.show(virtual_text_ns, buf, line_diags, { virtual_text = true })
end

---@note requires recursive statusline evaluation: %{%...%}
local function statusline(curwin, stlwin)
  local hi_prefix = curwin == stlwin and "StatusLine" or "StatusLineNC"
  local buf = api.nvim_win_get_buf(stlwin)
  local parts = {}

  local function add_part(hi_suffix, severity)
    local count = #diagnostic.get(buf, { severity = severity })
    if count > 0 then
      parts[#parts + 1] = ("%%#%s%s#%d%%*"):format(hi_prefix, hi_suffix, count)
    end
  end
  add_part("Error", diagnostic.severity.ERROR)
  add_part("Warn", diagnostic.severity.WARN)
  add_part("Info", diagnostic.severity.INFO)
  add_part("Hint", diagnostic.severity.HINT)

  return #parts > 0 and ("[" .. table.concat(parts, " ") .. "] ") or ""
end

fn.ConfDefineStatusLineComponent("diagnostic", statusline)

diagnostic.config {
  severity_sort = true,
  virtual_text = false,
  signs = false,
}

cmd [[
  augroup conf_diagnostic_statusline
    autocmd!
    autocmd DiagnosticChanged * redrawstatus
  augroup END

  augroup conf_diagnostic_virtual_text
    autocmd!
    autocmd DiagnosticChanged,CursorMoved *
            \ lua require('conf.diagnostic').update_virtual_text()
  augroup END
]]

map("n", "]<Space>", "<Cmd>lua vim.diagnostic.goto_next { float = false }<CR>")
map("n", "[<Space>", "<Cmd>lua vim.diagnostic.goto_prev { float = false }<CR>")
map(
  "n",
  { "<Space>k", "<Space>K" },
  "<Cmd>lua vim.diagnostic.open_float(nil, "
    .. "{ scope = 'cursor', border = 'single' })<CR>"
)

map("n", "<Space><Space>", "<Cmd>Telescope diagnostics bufnr=0<CR>")

return M
