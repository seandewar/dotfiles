local api = vim.api
local lsp = vim.lsp

local util = require "conf.util"
local bmap = util.bmap
local bunmap = util.bunmap

local M = {}

local last_progress_text = ""

function M.update_progress()
  local new_msgs = lsp.util.get_progress_messages()
  local msg = new_msgs[#new_msgs]

  local text = ""
  if msg and not msg.done then
    text = msg.name .. ": "

    if msg.progress then
      text = text .. msg.title

      if msg.message then
        text = text .. " " .. msg.message
      end
      if msg.percentage then
        text = text .. " " .. math.floor(msg.percentage) .. "%%"
      end
    else
      -- TODO: maybe show URI if msg.status == true?
      text = text .. msg.content
    end
  end

  last_progress_text = text
  vim.cmd "redrawstatus!"
end

function M.statusline(curwin, stlwin)
  if curwin == stlwin and last_progress_text ~= "" then
    return "[" .. last_progress_text .. "] "
  end

  local clients = vim.tbl_values(
    lsp.buf_get_clients(api.nvim_win_get_buf(stlwin))
  )
  if #clients == 0 then
    return ""
  elseif #clients == 1 then
    return "[" .. clients[1].name .. "] "
  else
    return "[" .. #clients .. " clients] "
  end
end

local buf_old_opts = {}

local function bopt(option, value)
  local buf = api.nvim_get_current_buf()
  buf_old_opts[buf] = vim.tbl_extend(
    "keep",
    buf_old_opts[buf] or {},
    { [option] = vim.bo[option] }
  )
  vim.bo[option] = value
end

function M.attach_buffer(args)
  -- Continue only for the first client attaching to the buffer.
  if vim.tbl_count(lsp.buf_get_clients(args.buf)) > 1 then
    return
  end

  api.nvim_buf_call(args.buf, function()
    bopt("omnifunc", "v:lua.vim.lsp.omnifunc")
    bopt("tagfunc", "v:lua.vim.lsp.tagfunc")
    bopt("formatexpr", "v:lua.vim.lsp.formatexpr()")

    bmap("n", "K", lsp.buf.hover, "LSP Hover")
    bmap({ "n", "i" }, "<C-K>", lsp.buf.signature_help, "LSP Signature Help")

    bmap("n", "<Space>i", lsp.buf.implementation, "LSP Implementations")
    bmap("n", "<Space>r", lsp.buf.references, "LSP References")
    bmap("n", "<Space>w", lsp.buf.workspace_symbol, "LSP Workspace Symbols")
    bmap("n", "<Space>d", lsp.buf.document_symbol, "LSP Document Symbols")

    bmap("n", "gd", lsp.buf.definition, "LSP Goto Definition")
    bmap("n", "gD", lsp.buf.declaration, "LSP Goto Declaration")
    bmap("n", "<Space>t", lsp.buf.type_definition, "LSP Goto Type Definition")

    bmap("n", "<Space>R", lsp.buf.rename, "LSP Rename")
    bmap("n", "<Space>f", function()
      lsp.buf.format { async = true }
    end, "LSP Formatting")
    bmap("n", "<Space>a", lsp.buf.code_action, "LSP Code Action")
    bmap("x", "<Space>f", "<Esc><Cmd>lua vim.lsp.buf.range_formatting()<CR>")
    bmap("x", "<Space>a", "<Esc><Cmd>lua vim.lsp.buf.range_code_action()<CR>")
  end)
end

function M.lspconfig_attach_curbuf(client)
  if client.name == "clangd" then
    bmap("n", "<Space>s", "<Cmd>ClangdSwitchSourceHeader<CR>")
  end
end

function M.detach_buffer(args)
  -- Last progress message may not be from any client attached to this buffer,
  -- but as we can't tell, just clear it so we don't have a lingering message.
  last_progress_text = ""

  -- Continue only for the last client detaching from the buffer.
  if not vim.tbl_isempty(lsp.buf_get_clients(args.buf)) then
    return
  end

  api.nvim_buf_call(args.buf, function()
    bunmap("n", "K")
    bunmap({ "n", "i" }, "<C-K>")

    bunmap("n", "<Space>i")
    bunmap("n", "<Space>r")
    bunmap("n", "<Space>w")
    bunmap("n", "<Space>d")

    bunmap("n", "gd")
    bunmap("n", "gD")
    bunmap("n", "<Space>t")

    bunmap("n", "<Space>R")
    bunmap("n", "<Space>f")
    bunmap("n", "<Space>a")
    bunmap("x", "<Space>f")
    bunmap("x", "<Space>a")

    -- lspconfig's on_attach (may not be defined)
    pcall(bunmap, "n", "<Space>s")

    for option, old_value in ipairs(buf_old_opts[args.buf] or {}) do
      vim.bo[option] = old_value
    end
    buf_old_opts[args.buf] = nil
  end)
end

return M
