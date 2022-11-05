local api = vim.api
local cmd = vim.cmd
local fn = vim.fn
local map = vim.keymap.set
local diagnostic = vim.diagnostic

local vtext_ns = api.nvim_create_namespace "conf_diagnostic_virt_text"

-- Display virtual text for the current line only
local function update_virtual_text(info)
  diagnostic.hide(vtext_ns) -- Clear stale virtual text
  local buf = info.buf
  local row = api.nvim_win_get_cursor(0)[1]
  diagnostic.show(
    vtext_ns,
    buf,
    diagnostic.get(buf, { lnum = row - 1 }),
    { virtual_text = true, underline = false, signs = false }
  )
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

fn["conf#statusline#define_component"]("diagnostic", statusline)

-- Define highlight groups for the statusline from the current colour scheme
local function define_stl_hls()
  local function define_hl(suffix, override)
    cmd.highlight {
      "StatusLine" .. suffix,
      fn["conf#colors#hl_override"](
        "StatusLine",
        override,
        { "ctermfg", "guifg" }
      ),
    }
    cmd.highlight {
      "StatusLineNC" .. suffix,
      fn["conf#colors#hl_override"](
        "StatusLineNC",
        override,
        { "ctermfg", "guifg" }
      ),
    }
  end

  define_hl("Error", "DiagnosticSignError")
  define_hl("Warn", "DiagnosticSignWarn")
  define_hl("Info", "DiagnosticSignInfo")
  define_hl("Hint", "DiagnosticSignHint")
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
  virtual_text = false,
  signs = false,
  float = { border = "single" },
}

local vtext_group = api.nvim_create_augroup("conf_diagnostic_virtual_text", {})
api.nvim_create_autocmd("DiagnosticChanged", {
  group = vtext_group,
  callback = function(info)
    if info.buf == api.nvim_get_current_buf() then
      update_virtual_text(info)
    end
  end,
})
api.nvim_create_autocmd("CursorMoved", {
  group = vtext_group,
  callback = update_virtual_text,
})

map("n", "]<Space>", function()
  diagnostic.goto_next { float = false }
end, {
  desc = "Next Diagnostic",
})
map("n", "[<Space>", function()
  diagnostic.goto_prev { float = false }
end, {
  desc = "Previous Diagnostic",
})

map("n", "<Space>k", function()
  diagnostic.open_float(nil, { scope = "cursor" })
end, {
  desc = "Cursor Diagnostics",
})

map("n", "<Space><Space>", "<Cmd>FzfLua diagnostics_document<CR>", {
  desc = "Buffer Diagnostics",
})
map("n", "<Space><C-Space>", "<Cmd>FzfLua diagnostics_workspace<CR>", {
  desc = "All Diagnostics",
})
