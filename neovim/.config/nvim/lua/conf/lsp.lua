local api = vim.api
local fn = vim.fn
local keymap = vim.keymap
local lsp = vim.lsp
local uv = vim.uv

local M = {}

local last_progress = nil
local progress_redraw_pending = false
local progress_redraw_debounce_timer = uv.new_timer()

local function update_progress(opts)
  local client = lsp.get_client_by_id(opts.data.client_id)
  if not client then
    return
  end

  last_progress = nil
  local msg = opts.data.params.value
  if msg.kind ~= "end" then
    local text = client.name .. ": " .. msg.title
    if msg.message then
      text = text .. " " .. msg.message
    end
    if msg.percentage then
      text = text .. " " .. math.floor(msg.percentage) .. "%"
    end

    last_progress = { client_id = client.id, text = text }
  end

  progress_redraw_pending = true

  local function redraw()
    if progress_redraw_pending then
      vim.cmd.redrawstatus()
      progress_redraw_pending = false
    end
  end

  -- Don't spam redraws.
  if progress_redraw_debounce_timer:get_due_in() == 0 then
    redraw()
    progress_redraw_debounce_timer:start(250, 0, vim.schedule_wrap(redraw))
  end
end

api.nvim_create_autocmd("LspProgress", {
  group = api.nvim_create_augroup("conf_lsp_progress", {}),
  callback = update_progress,
})

local function statusline(curwin, stlwin)
  local function escape(text)
    return text:gsub("%%", "%%%%")
  end

  if curwin == stlwin and last_progress then
    return "[LSP(" .. escape(last_progress.text) .. ")] "
  end

  local clients = lsp.get_clients { bufnr = api.nvim_win_get_buf(stlwin) }
  if #clients == 0 then
    return ""
  elseif #clients == 1 then
    return "[LSP(" .. escape(clients[1].name) .. ")] "
  else
    return "[LSP(" .. #clients .. " clients)] "
  end
end

fn["conf#statusline#define_component"]("lsp", statusline)

-- Similar to vim.lsp.formatexpr(), but uses vim.lsp.buf.format{async = true},
-- falling back to built-in formatting when automatically invoked.
function M.formatexpr()
  if vim.v.char ~= "" then
    return 1 -- Use built-in formatting when automatically invoked.
  end
  lsp.buf.format {
    async = true,
    range = {
      start = { vim.v.lnum, 0 },
      ["end"] = { vim.v.lnum + vim.v.count - 1, 0 },
    },
  }
  return 0
end

function M.setup_attached_buffers(client_id, detaching)
  for _, buf in ipairs(lsp.get_buffers_by_client_id(client_id)) do
    local buf_clients = vim.tbl_filter(function(c)
      return not detaching or c.id ~= client_id
    end, lsp.get_clients { bufnr = buf })

    local function buf_supports_method(method)
      return vim.iter(buf_clients):any(function(c)
        return c:supports_method(method)
      end)
    end
    local function buf_reset_option(option)
      vim.bo[buf][option] =
        api.nvim_get_option_value(option, { filetype = vim.bo[buf].filetype })
    end

    if buf_supports_method "textDocument/hover" then
      keymap.set("n", "K", lsp.buf.hover, { buffer = buf, desc = "LSP Hover" })
    else
      pcall(keymap.del, "n", "K", { buffer = buf })
    end

    if buf_supports_method "textDocument/definition" then
      vim.bo[buf].tagfunc = "v:lua.vim.lsp.tagfunc"
      keymap.set(
        "n",
        "gd",
        lsp.buf.definition,
        { buffer = buf, desc = "LSP Definition" }
      )
    else
      buf_reset_option "tagfunc"
      pcall(keymap.del, "n", "gd", { buffer = buf })
    end

    if buf_supports_method "textDocument/declaration" then
      keymap.set(
        "n",
        "gD",
        lsp.buf.declaration,
        { buffer = buf, desc = "LSP Declaration" }
      )
    else
      pcall(keymap.del, "n", "gD", { buffer = buf })
    end

    if buf_supports_method "textDocument/completion" then
      vim.bo[buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    else
      buf_reset_option "omnifunc"
    end

    if buf_supports_method "textDocument/rangeFormatting" then
      -- Prefer ours.
      vim.bo[buf].formatexpr = "v:lua.require'conf.lsp'.formatexpr()"
    else
      buf_reset_option "formatexpr"
    end

    local folding = require "conf.folding"
    folding.enable(
      buf,
      folding.type.LSP,
      buf_supports_method "textDocument/foldingRange"
    )
  end
end

function M.attach_buffer(args)
  M.setup_attached_buffers(args.data.client_id)
  lsp.completion.enable(true, args.data.client_id, args.bufnr)

  -- Schedule, as the window may not have been drawn yet, which could cause
  -- a full screen redraw from `:redrawstatus!`; this can introduce a "flicker"
  -- if another redraw happens later (e.g: setting cursor position).
  vim.schedule(function()
    vim.cmd.redrawstatus { bang = true }
  end)
end

function M.detach_buffer(args)
  M.setup_attached_buffers(args.data.client_id, true)
  lsp.completion.enable(false, args.data.client_id, args.bufnr)

  if last_progress and last_progress.client_id == args.data.client_id then
    last_progress = nil

    -- Schedule, as the client hasn't finished detaching yet.
    vim.schedule(function()
      vim.cmd.redrawstatus { bang = true }
    end)
  end
end

return M
