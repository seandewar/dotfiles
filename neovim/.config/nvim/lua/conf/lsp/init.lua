local cmd = vim.cmd
local lsp = vim.lsp

cmd "packadd nvim-lspconfig"
local lspconfig = require "lspconfig"

local servers = require "conf.lsp.servers"
local bmap = require("conf.util").bmap

local M = {
  progress_clear_ms = 3000,
  progress = "",
}

local function is_attached(buf)
  return vim.tbl_count(lsp.buf_get_clients(buf)) ~= 0
end

function M.statusline(is_current)
  if is_current and M.progress ~= "" then
    return "[" .. M.progress .. "] "
  end
  return is_attached() and "[LSP] " or ""
end

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
  cmd "redrawstatus"

  if M.progress_clear_timer then
    M.progress_clear_timer:stop()
  end
  if not msg.done then
    M.progress_clear_timer = vim.defer_fn(function()
      M.progress = ""
      cmd "redrawstatus"
    end, M.progress_clear_ms)
  end
end

local function on_attach(client, _)
  vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
  vim.opt_local.tagfunc = "v:lua.vim.lsp.tagfunc"
  vim.opt_local.formatexpr = "v:lua.vim.lsp.formatexpr()"

  if client.name == "clangd" then
    bmap("n", "<Space>s", "<Cmd>ClangdSwitchSourceHeader<CR>")
  end

  bmap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>")
  bmap({ "n", "i" }, "<C-K>", "<Cmd>lua vim.lsp.buf.signature_help()<CR>")

  bmap("n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>")
  bmap("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>")
  bmap("n", "<Space>t", "<Cmd>lua vim.lsp.buf.type_definition()<CR>")
  bmap("n", "<Space>i", "<Cmd>Telescope lsp_implementations<CR>")
  bmap("n", "<Space>r", "<Cmd>Telescope lsp_references<CR>")

  bmap("n", "<Space>R", "<Cmd>lua vim.lsp.buf.rename()<CR>")
  bmap("n", "<Space>f", "<Cmd>lua vim.lsp.buf.formatting()<CR>")
  bmap("x", "<Space>f", "<Esc><Cmd>lua vim.lsp.buf.range_formatting()<CR>")
  bmap("n", "<Space>a", "<Cmd>lua vim.lsp.buf.code_action()<CR>")
  bmap("x", "<Space>a", "<Esc><Cmd>lua vim.lsp.buf.range_code_action()<CR>")

  bmap("n", "<Space>w", "<Cmd>Telescope lsp_dynamic_workspace_symbols<CR>")
  bmap("n", "<Space>d", "<Cmd>Telescope lsp_document_symbols<CR>")
end

-- vim-vsnip-integ doesn't enable snippetSupport for us
local capabilities = lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

local default_config = {
  on_attach = on_attach,
  capabilities = capabilities,
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

for _, config in ipairs(servers) do
  local name
  if type(config) == "string" then
    name = config
    config = {}
  else
    name = config.name
    config.name = nil
  end

  lspconfig[name].setup(vim.tbl_deep_extend("force", default_config, config))
end

cmd [[
  augroup conf_lsp_progress
    autocmd!
    autocmd User LspProgressUpdate lua require("conf.lsp").update_progress()
  augroup END
]]

return M
