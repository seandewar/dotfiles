local api = vim.api
local fn = vim.fn
local lsp = vim.lsp

local map = vim.keymap.set
local unmap = vim.keymap.del

local M = {}

local last_progress = nil

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
      text = text .. " " .. math.floor(msg.percentage) .. "%%"
    end

    last_progress = { client_id = client.id, text = text }
  end

  vim.cmd.redrawstatus()
end

api.nvim_create_autocmd("LspProgress", {
  group = api.nvim_create_augroup("conf_lsp_progress", {}),
  callback = update_progress,
})

local function statusline(curwin, stlwin)
  if curwin == stlwin and last_progress then
    return "[" .. last_progress.text .. "] "
  end

  local clients = lsp.get_clients { bufnr = api.nvim_win_get_buf(stlwin) }
  if #clients == 0 then
    return ""
  elseif #clients == 1 then
    return "[" .. clients[1].name .. "] "
  else
    return "[" .. #clients .. " clients] "
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

function M.lspconfig_attach_curbuf(client)
  if client.name == "clangd" then
    map("n", "<Space>s", "<Cmd>ClangdSwitchSourceHeader<CR>", {
      buffer = true,
    })
  end
end

function M.attach_buffer(args)
  local client = vim.lsp.get_client_by_id(args.data.client_id)
  if client.name == "zls" then
    -- zls already runs zig ast-check, so no need to have zig.vim run it too.
    -- Unfortunately, this cannot be set per-buffer.
    local group =
      api.nvim_create_augroup("conf_lsp_use_zls_errors", { clear = false })
    api.nvim_create_autocmd("BufEnter", {
      group = group,
      buffer = args.buf,
      command = "let g:zig_fmt_parse_errors = 0",
    })
    api.nvim_create_autocmd("BufLeave", {
      group = group,
      buffer = args.buf,
      command = "let g:zig_fmt_parse_errors = 1",
    })
    if api.nvim_get_current_buf() == args.buf then
      vim.g.zig_fmt_parse_errors = false
    end
  end

  -- Schedule, as the window may not have been drawn yet, which could cause
  -- a full screen redraw from `:redrawstatus!`; this can introduce a "flicker"
  -- if another redraw happens later (e.g: setting cursor position).
  vim.schedule(function()
    vim.cmd.redrawstatus { bang = true }
  end)

  -- Continue only for the first client attaching to the buffer.
  if #lsp.get_clients { bufnr = args.buf } > 1 then
    return
  end

  api.nvim_buf_call(args.buf, function()
    vim.bo.omnifunc = "v:lua.vim.lsp.omnifunc"
    vim.bo.tagfunc = "v:lua.vim.lsp.tagfunc"
    vim.bo.formatexpr = "v:lua.require'conf.lsp'.formatexpr()" -- Prefer ours.

    -- These maps have default functions, so define them here as buffer-local.
    map("n", "K", lsp.buf.hover, { buffer = true, desc = "LSP Hover" })
    map(
      "n",
      "gd",
      lsp.buf.definition,
      { buffer = true, desc = "LSP Definition" }
    )
    map(
      "n",
      "gD",
      lsp.buf.declaration,
      { buffer = true, desc = "LSP Declaration" }
    )
  end)
end

function M.detach_buffer(args)
  if last_progress and last_progress.client_id == args.data.client_id then
    last_progress = nil

    -- Schedule, as the client hasn't finished detaching yet.
    vim.schedule(function()
      vim.cmd.redrawstatus { bang = true }
    end)
  end

  local client = vim.lsp.get_client_by_id(args.data.client_id)
  if client.name == "zls" then
    -- Undo zls-specific attach settings.
    api.nvim_clear_autocmds {
      group = "conf_lsp_use_zls_errors",
      buffer = args.buf,
    }
    if api.nvim_get_current_buf() == args.buf then
      vim.g.zig_fmt_parse_errors = true
    end
  end

  -- Continue only for the last client detaching from the buffer.
  if #lsp.get_clients { bufnr = args.buf } > 1 then
    return
  end

  api.nvim_buf_call(args.buf, function()
    unmap("n", "K", { buffer = true })
    unmap("n", "gd", { buffer = true })
    unmap("n", "gD", { buffer = true })

    -- Server-specific mappings.
    if fn.mapcheck("<Space>s", "n") ~= "" then -- clangd
      unmap("n", "<Space>s", { buffer = true })
    end

    -- Restore the original buffer-local option values for the filetype.
    for _, option in ipairs { "omnifunc", "tagfunc", "formatexpr" } do
      local info = api.nvim_get_option_info2(option, { buf = 0 })
      vim.bo[option] = info.default ~= "" and info.default or vim.go[option]
    end
  end)
end

return M
