local api = vim.api
local fn = vim.fn
local map = vim.keymap.set
local diagnostic = vim.diagnostic

local virt_text_ns = api.nvim_create_namespace "conf_diagnostic_virt_text"

-- Display virtual text for the current line only
local function update_virtual_text()
  if api.nvim_get_mode().mode:match "i" then
    return
  end
  local buf = api.nvim_get_current_buf()
  local row = api.nvim_win_get_cursor(0)[1]
  local line_diags = diagnostic.get(buf, { lnum = row - 1 })
  diagnostic.show(virt_text_ns, buf, line_diags, { virtual_text = true })
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
    vim.cmd(
      ([[
         highlight StatusLine%s %s
         highlight StatusLineNC%s %s
       ]]):format(
        suffix,
        fn["conf#colors#hl_override"](
          "StatusLine",
          override,
          { "ctermfg", "guifg" }
        ),
        suffix,
        fn["conf#colors#hl_override"](
          "StatusLineNC",
          override,
          { "ctermfg", "guifg" }
        )
      )
    )
  end

  define_hl("Error", "DiagnosticSignError")
  define_hl("Warn", "DiagnosticSignWarn")
  define_hl("Info", "DiagnosticSignInfo")
  define_hl("Hint", "DiagnosticSignHint")
end

api.nvim_create_autocmd("ColorScheme", {
  group = api.nvim_create_augroup("conf_diagnostic_statusline_highlights", {}),
  callback = define_stl_hls,
})
define_stl_hls()

diagnostic.config {
  severity_sort = true,
  virtual_text = false,
  signs = false,
}

api.nvim_create_autocmd({ "DiagnosticChanged", "CursorMoved" }, {
  group = api.nvim_create_augroup("conf_diagnostic_virtual_text", {}),
  callback = update_virtual_text,
})

map("n", "]<Space>", function()
  diagnostic.goto_next { float = false }
end, {
  desc = "Goto Next Diagnostic",
})
map("n", "[<Space>", function()
  diagnostic.goto_prev { float = false }
end, {
  desc = "Goto Previous Diagnostic",
})

map("n", "<Space>k", function()
  diagnostic.open_float(nil, { scope = "cursor", border = "single" })
end, {
  desc = "Diagnostics Under Cursor",
})

map("n", "<Space><Space>", function()
  diagnostic.setloclist({ title = "Buffer Diagnostics", open = false })
  vim.cmd "lwindow"
end, {
  desc = "Buffer Diagnostics",
})
map("n", "<Space><C-Space>", function()
  diagnostic.setqflist({ title = "All Diagnostics", open = false })
  vim.cmd "cwindow"
end, {
  desc = "All Diagnostics",
})
