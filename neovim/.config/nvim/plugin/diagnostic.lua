local api = vim.api
local diagnostic = vim.diagnostic
local fn = vim.fn
local keymap = vim.keymap

---@note requires recursive statusline evaluation: %{%...%}
local function statusline(curwin, stlwin)
  local hl_prefix = curwin == stlwin and "StatusLine" or "StatusLineNC"
  local buf = api.nvim_win_get_buf(stlwin)
  local parts = {}

  local function add_part(level, severity)
    local count = #diagnostic.get(buf, { severity = severity })
    if count > 0 then
      parts[#parts + 1] = ("%%#%s%s#%d%%*"):format(hl_prefix, level, count)
    end
  end
  add_part("Error", diagnostic.severity.ERROR)
  add_part("Warn", diagnostic.severity.WARN)
  add_part("Info", diagnostic.severity.INFO)
  add_part("Hint", diagnostic.severity.HINT)

  return #parts > 0 and ("[" .. table.concat(parts, " ") .. "] ") or ""
end

fn["conf#statusline#define_component"]("diagnostic", statusline)

-- Define highlight groups for the statusline from the current colour scheme
local function define_stl_hls()
  for _, level in ipairs { "Error", "Warn", "Info", "Hint" } do
    local level_def =
      api.nvim_get_hl(0, { name = "DiagnosticSign" .. level, link = false })

    for _, stl_hl in ipairs { "StatusLine", "StatusLineNC" } do
      local stl_def = api.nvim_get_hl(0, { name = stl_hl, link = false })
      api.nvim_set_hl(
        0,
        stl_hl .. level,
        vim.tbl_deep_extend(
          "force",
          level_def,
          { bg = stl_def.bg, ctermbg = stl_def.ctermbg }
        )
      )
    end
  end
end

local stl_group = api.nvim_create_augroup("conf_diagnostic_statusline", {})

api.nvim_create_autocmd("DiagnosticChanged", {
  group = stl_group,
  command = "redrawstatus!",
})
api.nvim_create_autocmd("ColorScheme", {
  group = stl_group,
  callback = define_stl_hls,
})
define_stl_hls()

diagnostic.config {
  severity_sort = true,
  virtual_text = {
    current_line = true,
    spacing = 2,
    prefix = function(diag, i, n)
      local name = diagnostic.severity[diag.severity]
      return name and name:sub(1, 1):upper() or "D"
    end,
  },
  signs = false,
  float = {
    source = true,
  },
}

-- Attempt to show either cursor or line diagnostics, in that order.
keymap.set("n", "<C-W>d", function()
  if
    diagnostic.open_float { scope = "c", header = "Cursor Diagnostics:" }
    or diagnostic.open_float { scope = "l", header = "Line Diagnostics:" }
  then
    return
  end
  require("conf.util").echo { { "No diagnostics found", "WarningMsg" } }
end, {
  desc = "Floating Diagnostics",
})

keymap.set("n", "<Space><Space>", function()
  if vim.g.loaded_fzf_lua ~= nil then
    require("fzf-lua").diagnostics_document()
  else
    diagnostic.setloclist { title = "Buffer Diagnostics" }
  end
end, {
  desc = "Buffer Diagnostics",
})
keymap.set("n", "<Space><C-Space>", function()
  if vim.g.loaded_fzf_lua ~= nil then
    require("fzf-lua").diagnostics_workspace()
  else
    diagnostic.setqflist { title = "All Diagnostics" }
  end
end, {
  desc = "All Diagnostics",
})
