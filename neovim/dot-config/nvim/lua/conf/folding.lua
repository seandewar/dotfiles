local api = vim.api
local bit = require "bit"

local M = {
  -- Fold configuration type bits; larger bit == higher priority.
  -- Values should be powers of 2.
  type = {
    TREESITTER = 1,
    LSP = 2,
  },
}

local function set_opts(buf, type)
  -- Default to nil: the global ("allbuf") values for the windows.
  local foldmethod, foldexpr, foldtext

  if type == M.type.TREESITTER then
    foldmethod = "expr"
    foldexpr = "v:lua.vim.treesitter.foldexpr()"
  elseif type == M.type.LSP then
    foldmethod = "expr"
    foldexpr = "v:lua.vim.lsp.foldexpr()"
    -- LSP supports &foldtext showing the "collapsedText" from the server, but I
    -- prefer using my &foldtext's global value instead.
    -- foldtext = "v:lua.vim.lsp.foldtext()"
  end

  --- @param win integer
  local function set_onebuf_opts(win)
    vim.wo[win][0].foldmethod = foldmethod
    vim.wo[win][0].foldexpr = foldexpr
    vim.wo[win][0].foldtext = foldtext
  end

  for _, win in ipairs(api.nvim_list_wins()) do
    -- Don't mess with diff windows or windows where the &foldmethod was set by
    -- a modeline.
    if
      not vim.wo[win][0].diff
      and api.nvim_get_option_info2("foldmethod", { win = win }).last_set_sid
        ~= -1 -- SID_MODELINE
    then
      -- vim.wo currently only supports setting the "onebuf" value for the
      -- current buffer in a window. For windows where the buffer isn't current,
      -- create an autocommand to set the options when becomes current; this is
      -- less prone to side-effects compared to temporarily switching buffers.
      --
      -- TODO: replace with vim.wo[win][buf] when it supports bufs other than 0.

      if api.nvim_win_get_buf(win) == buf then
        set_onebuf_opts(win)
      else
        local augroup = api.nvim_create_augroup("conf_folding_win_" .. win, {})

        api.nvim_create_autocmd("BufEnter", {
          group = augroup,
          buffer = buf,
          callback = function()
            if api.nvim_get_current_win() == win then
              set_onebuf_opts(0)
              api.nvim_del_augroup_by_id(augroup)
            end
          end,
        })
        api.nvim_create_autocmd("WinClosed", {
          group = augroup,
          pattern = tostring(win),
          callback = function()
            api.nvim_del_augroup_by_id(augroup)
          end,
        })
      end
    end
  end
end

local function top_type(types)
  local i = 0
  while types ~= 0 do
    i = i + 1
    types = bit.rshift(types, 1)
  end
  return i > 0 and bit.lshift(1, i - 1) or 0
end

local buf_types = {}

function M.enable(buf, type, enable)
  buf = buf ~= 0 and buf or api.nvim_get_current_buf()
  enable = enable == nil or enable

  if enable then
    buf_types[buf] = buf_types[buf] or 0

    if type > top_type(buf_types[buf]) then
      set_opts(buf, type)
    end
    buf_types[buf] = bit.bor(buf_types[buf], type)
  else
    if bit.band(buf_types[buf] or 0, type) == 0 then
      return
    end

    buf_types[buf] = bit.band(buf_types[buf], bit.bnot(type))
    local top = top_type(buf_types[buf])
    if type > top then
      set_opts(buf, top)
    end
  end
end

return M
