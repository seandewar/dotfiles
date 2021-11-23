if vim.fn.has "nvim-0.6" == 0 then
  return nil
end

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

-- TODO: move lsp_workspace_diagnostics to diagnostic config when a generic
-- vim.diagnostic picker is added
local function on_attach(client, _)
  vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
  vim.opt_local.tagfunc = "v:lua.vim.lsp.tagfunc"
  vim.opt_local.formatexpr = "v:lua.vim.lsp.formatexpr()"

  if client.name == "clangd" then
    bmap("n", "<space>s", "<cmd>ClangdSwitchSourceHeader<cr>")
  end

  bmap("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>")
  bmap({ "n", "i" }, "<c-k>", "<cmd>lua vim.lsp.buf.signature_help()<cr>")

  bmap("n", "<space><space>", "<cmd>Telescope lsp_workspace_diagnostics<cr>")

  bmap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>")
  bmap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>")
  bmap("n", "<space>t", "<cmd>lua vim.lsp.buf.type_definition()<cr>")
  bmap("n", "<space>i", "<cmd>Telescope lsp_implementations<cr>")
  bmap("n", "<space>r", "<cmd>Telescope lsp_references<cr>")

  bmap("n", "<space>R", "<cmd>lua vim.lsp.buf.rename()<cr>")
  bmap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<cr>")
  bmap("x", "<space>f", "<esc><cmd>lua vim.lsp.buf.range_formatting()<cr>")
  bmap("n", "<space>a", "<cmd>Telescope lsp_code_actions<cr>")
  bmap("x", "<space>a", "<esc><cmd>Telescope lsp_range_code_actions<cr>")

  bmap("n", "<space>w", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>")
  bmap("n", "<space>d", "<cmd>Telescope lsp_document_symbols<cr>")
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
