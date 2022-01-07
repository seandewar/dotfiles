local cmd = vim.cmd
local api = vim.api
local fn = vim.fn
local lsp = vim.lsp

local servers = require "conf.lsp.servers"

cmd "packadd nvim-lspconfig"
local lspconfig = require "lspconfig"

local M = {
  progress_clear_ms = 10000,
  progress = "",
}

function M.update_progress()
  local new_msgs = lsp.util.get_progress_messages()
  local msg = new_msgs[#new_msgs]

  local progress = ""
  if msg and not msg.done then
    progress = msg.name .. ": "

    if msg.progress then
      progress = progress .. msg.title

      if msg.message then
        progress = progress .. " " .. msg.message
      end
      if msg.percentage then
        progress = progress .. " " .. math.floor(msg.percentage) .. "%%"
      end
    else
      -- TODO: maybe show URI if msg.status == true?
      progress = progress .. msg.content
    end
  end

  M.progress = progress
  cmd "redrawstatus!"

  if M.progress_clear_timer then
    M.progress_clear_timer:stop()
  end
  if not msg.done then
    M.progress_clear_timer = vim.defer_fn(function()
      M.progress = ""
      cmd "redrawstatus!"
    end, M.progress_clear_ms)
  end
end

local function statusline(curwin, stlwin)
  if curwin == stlwin and M.progress ~= "" then
    return "[" .. M.progress .. "] "
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

fn.ConfDefineStatusLineComponent("lsp", statusline)

local function on_attach(client, _)
  local opt = vim.opt_local
  local map = function(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = true, desc = desc })
  end

  opt.omnifunc = "v:lua.vim.lsp.omnifunc"
  opt.tagfunc = "v:lua.vim.lsp.tagfunc"
  opt.formatexpr = "v:lua.vim.lsp.formatexpr()"

  map("n", "K", lsp.buf.hover, "LSP Hover")
  map({ "n", "i" }, "<C-K>", lsp.buf.signature_help, "LSP Signature Help")
  map("n", "gd", lsp.buf.definition, "LSP Goto Definition")
  map("n", "gD", lsp.buf.declaration, "LSP Goto Declaration")
  map("n", "<Space>t", lsp.buf.type_definition, "LSP Goto Type Definition")
  map("n", "<Space>R", lsp.buf.rename, "LSP Rename")
  map("n", "<Space>f", lsp.buf.formatting, "LSP Formatting")
  map("n", "<Space>a", lsp.buf.code_action, "LSP Code Action")
  map("x", "<Space>f", "<Esc><Cmd>lua vim.lsp.buf.range_formatting()<CR>")
  map("x", "<Space>a", "<Esc><Cmd>lua vim.lsp.buf.range_code_action()<CR>")

  -- telescope.nvim
  map("n", "<Space>i", "<Cmd>Telescope lsp_implementations<CR>")
  map("n", "<Space>r", "<Cmd>Telescope lsp_references<CR>")
  map("n", "<Space>w", "<Cmd>Telescope lsp_dynamic_workspace_symbols<CR>")
  map("n", "<Space>d", "<Cmd>Telescope lsp_document_symbols<CR>")

  -- server-specific commands
  if client.name == "clangd" then
    map("n", "<Space>s", "<Cmd>ClangdSwitchSourceHeader<CR>")
  end
end

-- vim-vsnip-integ doesn't enable snippetSupport for us
local capabilities = lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

lspconfig.util.default_config = vim.tbl_extend(
  "force",
  lspconfig.util.default_config,
  {
    on_attach = on_attach,
    capabilities = capabilities,
    flags = { debounce_text_changes = 150 },
    handlers = {
      ["textDocument/hover"] = lsp.with(lsp.handlers.hover, {
        border = "single",
      }),
      ["textDocument/signatureHelp"] = lsp.with(
        lsp.handlers.signature_help,
        { border = "single" }
      ),
      ["textDocument/formatting"] = function(...)
        lsp.handlers["textDocument/formatting"](...)
        cmd "echo 'Buffer formatted!'"
      end,
      ["textDocument/rangeFormatting"] = function(...)
        lsp.handlers["textDocument/rangeFormatting"](...)
        cmd "echo 'Range formatted!'"
      end,
    },
  }
)

for _, config in ipairs(servers) do
  local name
  if type(config) == "string" then
    name = config
    config = {}
  else
    name = config.name
    config.name = nil
  end
  lspconfig[name].setup(config)
end

cmd [[
  augroup conf_lsp_progress
    autocmd!
    autocmd User LspProgressUpdate lua require("conf.lsp").update_progress()
  augroup END
]]

return M
