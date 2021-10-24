if vim.fn.has "nvim-0.6" == 0 then
  return nil
end

local diagnostic = vim.diagnostic
local map = require("conf.util").map

local M = {}

--- Note: requires recursive statusline evaluation: %{%...%}
function M.statusline(is_current)
  local hi_prefix = is_current and "StatusLine" or "StatusLineNC"
  local parts = {}

  local function add_part(hi_suffix, severity)
    local count = #diagnostic.get(0, { severity = severity })
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

diagnostic.config { severity_sort = true }

vim.cmd [[
  augroup conf_diagnostic_update_statusline
    autocmd!
    autocmd User DiagnosticsChanged redrawstatus!
  augroup END
]]

map(
  "n",
  "]<space>",
  "<cmd>lua vim.diagnostic.goto_next({float = {border = 'single'}})<cr>"
)
map(
  "n",
  "[<space>",
  "<cmd>lua vim.diagnostic.goto_prev({float = {border = 'single'}})<cr>"
)

return M
