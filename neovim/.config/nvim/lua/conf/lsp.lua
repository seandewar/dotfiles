local api = vim.api
local fn = vim.fn
local lsp = vim.lsp

local map = vim.keymap.set
local unmap = vim.keymap.del

local M = {}

local last_progress_text = ""

local function update_progress(opts)
  local client = lsp.get_client_by_id(opts.data.client_id)
  if not client then
    return
  end

  local text = ""
  local msg = opts.data.result.value
  if msg.kind ~= "end" then
    text = client.name .. ": " .. msg.title
    if msg.message then
      text = text .. " " .. msg.message
    end
    if msg.percentage then
      text = text .. " " .. math.floor(msg.percentage) .. "%%"
    end
  end

  last_progress_text = text
  vim.cmd.redrawstatus()
end

api.nvim_create_autocmd("LspProgress", {
  group = api.nvim_create_augroup("conf_lsp_progress", {}),
  callback = update_progress,
})

local function statusline(curwin, stlwin)
  if curwin == stlwin and last_progress_text ~= "" then
    return "[" .. last_progress_text .. "] "
  end

  local clients =
    vim.tbl_values(lsp.buf_get_clients(api.nvim_win_get_buf(stlwin)))
  if #clients == 0 then
    return ""
  elseif #clients == 1 then
    return "[" .. clients[1].name .. "] "
  else
    return "[" .. #clients .. " clients] "
  end
end

fn["conf#statusline#define_component"]("lsp", statusline)

function M.lspconfig_attach_curbuf(client)
  if client.name == "clangd" then
    map("n", "<Space>s", "<Cmd>ClangdSwitchSourceHeader<CR>", {
      buffer = true,
    })
  end
end

local buf_saved_opts = {}

local function bopt(option, value)
  local buf = api.nvim_get_current_buf()
  buf_saved_opts[buf] = vim.tbl_extend(
    "keep",
    buf_saved_opts[buf] or {},
    { [option] = vim.bo[option] }
  )
  vim.bo[option] = value
end

function M.attach_buffer(args)
  local client = vim.lsp.get_client_by_id(args.data.client_id)
  if client.name == "zls" then
    -- zls already runs zig ast-check, so no need to have zig.vim run it too.
    -- Unfortunately, this cannot be set per-buffer.
    vim.g.zig_fmt_parse_errors = false
  end

  -- Continue only for the first client attaching to the buffer.
  if vim.tbl_count(lsp.buf_get_clients(args.buf)) > 1 then
    return
  end

  api.nvim_buf_call(args.buf, function()
    bopt("omnifunc", "v:lua.vim.lsp.omnifunc")
    bopt("tagfunc", "v:lua.vim.lsp.tagfunc")
    bopt("formatexpr", "v:lua.vim.lsp.formatexpr()")

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
  -- Last progress message may not be from any client attached to this buffer,
  -- but as we can't tell, just clear it so we don't have a lingering message.
  last_progress_text = ""

  -- Continue only for the last client detaching from the buffer.
  if vim.tbl_count(lsp.buf_get_clients(args.buf)) > 1 then
    return
  end

  api.nvim_buf_call(args.buf, function()
    unmap("n", "K", { buffer = true })
    unmap("n", "gd", { buffer = true })
    unmap("n", "gD", { buffer = true })

    -- lspconfig (may not be defined, hence pcall to ignore errors)
    pcall(unmap, "n", "<Space>s", { buffer = true })

    for option, old_value in ipairs(buf_saved_opts[args.buf] or {}) do
      vim.bo[option] = old_value
    end
    buf_saved_opts[args.buf] = nil
  end)
end

return M
