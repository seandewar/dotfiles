local api = vim.api
local fn = vim.fn

local M = {
  order = {
    "main",
    "git",
    "lsp",
    "diagnostic",
    "ruler",
  },

  --- @type table<string, string | fun(integer, integer): string>
  components = {
    main = "%(%w %)%(%q %)"
      .. "%(%{v:lua.require'conf.statusline'.buf_name()} %)"
      .. "%(%{v:lua.require'conf.statusline'.qf_title()} %)"
      .. "%([%M%R%{&binary ? ',BIN' : ''}"
      .. "%{!empty(&filetype) ? ',' .. &filetype : ''}"
      .. "%{get(b:, 'ts_highlight') ? ',TS' : ''}"
      .. "%{&spell ? ',' .. &spelllang : ''}] %)",

    ruler = "%=%(%l,%c%V %P%)",
  },
}

--- @param tp_buf integer?
function M.buf_name(tp_buf)
  local name = tp_buf and fn.pathshorten(fn.expand(("#%d:p:~"):format(tp_buf)))
    or fn.expand "%:p:~:."
  if name ~= "" then
    return name
  end

  tp_buf = tp_buf or api.nvim_get_current_buf()
  --- @diagnostic disable-next-line: undefined-field
  if fn.getbufinfo(tp_buf)[1].command == 1 then
    return "[Command Line]"
  end

  local buftype = vim.bo[tp_buf].buftype
  if buftype == "prompt" then
    return "[Prompt]"
  elseif
    buftype == "nofile"
    or buftype == "acwrite"
    or buftype == "terminal"
  then
    return "[Scratch]"
  end

  return "[No Name]"
end

function M.qf_title()
  local title = vim.w.quickfix_title or ""
  return (title ~= ":setqflist()" and title ~= ":setloclist()") and title or ""
end

function M.statusline()
  local win = api.nvim_get_current_win()
  local stl_win = vim.g.statusline_winid

  return vim
    .iter(M.order)
    :map(function(name)
      local component = M.components[name] or ""
      return type(component) == "function" and component(win, stl_win)
        or component
    end)
    :join ""
end

--- @param tp_nr integer
function M.tp_label(tp_nr)
  local bufs = fn.tabpagebuflist(tp_nr)
  local modified = vim.iter(bufs):find(function(b)
    return vim.bo[b].modified
  end)
  local prefix = (" %d%s%s "):format(
    tp_nr,
    tp_nr == fn.tabpagenr "#" and "#" or "",
    modified and "+" or ""
  )

  -- Uses prefix byte count rather than its actual screen length, but is simple.
  local tp_count = fn.tabpagenr "$"
  local editor_cols = vim.o.columns
  -- TODO: improve the handling of this...
  local max_cols = math.floor(editor_cols / tp_count) - #prefix
  if tp_nr == fn.tabpagenr() then
    max_cols = max_cols + (editor_cols % tp_count)
  end
  if max_cols <= 0 then
    return ""
  end

  return (" %s%s"):format(
    prefix,
    (M.buf_name(bufs[fn.tabpagewinnr(tp_nr)]) .. " "):sub(1, max_cols)
  )
end

function M.tabline()
  local parts = {}
  local tp_nr = fn.tabpagenr()
  for i = 1, fn.tabpagenr "$" do
    parts[#parts + 1] = ("%%#TabLine%s#%%%dT%%{%%v:lua.require'conf.statusline'.tp_label(%d)%%}"):format(
      i == tp_nr and "Sel" or "",
      i,
      i
    )
  end

  parts[#parts + 1] = "%#TabLineFill#"
  return table.concat(parts)
end

function M.rulerformat()
  return M.components.ruler
end

return M
