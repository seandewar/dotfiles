--------------------------------------------------------------------------------
-- Sean Dewar's Neovim 0.5+ LSP Client Config <https://github.com/seandewar>  --
--------------------------------------------------------------------------------
local lsp, api = vim.lsp, vim.api
local lspconfig = require "lspconfig"

local kmap = function(mode, lhs, rhs)
  api.nvim_buf_set_keymap(0, mode, lhs, rhs, { noremap = true, silent = true })
end

local echo = function(message)
  api.nvim_echo({ { message } }, false, {})
end

-- Global, as this file isn't usually require()'d (allows reloading)
lsp_conf = {
  progress = "",
}

-- Status Line Functions {{{1
lsp_conf.eval_statusline = function(is_current)
  is_current = is_current ~= 0
  local progress = is_current and (lsp_conf.progress .. " ") or ""

  if vim.tbl_isempty(lsp.buf_get_clients(0)) then
    return progress
  end

  local errors = lsp.diagnostic.get_count(0, "Error")
  local warns = lsp.diagnostic.get_count(0, "Warning")
  local infos = lsp.diagnostic.get_count(0, "Info")

  local hi_prefix = "LspDiagnosticsStl"
  if not is_current then
    hi_prefix = hi_prefix .. "NC"
  end

  local parts = {}
  if errors > 0 then
    parts[#parts + 1] = "%#" .. hi_prefix .. "Error#" .. errors .. "%*"
  end
  if warns > 0 then
    parts[#parts + 1] = "%#" .. hi_prefix .. "Warning#" .. warns .. "%*"
  end
  if infos > 0 then
    parts[#parts + 1] = "%#" .. hi_prefix .. "Information#" .. infos .. "%*"
  end

  local status = "["
    .. (#parts > 0 and table.concat(parts, " ") or "OK")
    .. "] "
  return status .. progress
end

lsp_conf.statusline = function(is_current)
  return "%{%v:lua.lsp_conf.eval_statusline(" .. is_current .. ")%}"
end

lsp_conf.update_progress = function()
  local new_msgs = lsp.util.get_progress_messages()
  local msg = new_msgs[#new_msgs]

  local progress = ""
  if msg then
    progress = msg.name .. ": "

    if msg.progress then
      progress = progress .. msg.title .. " "
      if msg.message then
        progress = progress .. msg.message .. " "
      end
      if msg.percentage then
        progress = progress .. "(" .. math.floor(msg.percentage) .. "%%)"
      end
    elseif msg.status then
      if msg.uri then
        -- TODO: show this maybe?
      end
      progress = progress .. msg.content
    else
      progress = progress .. msg.content
    end
  end

  lsp_conf.progress = progress
  vim.cmd "redrawstatus"

  if lsp_conf.progress_clear_timer then
    lsp_conf.progress_clear_timer:stop()
  end
  lsp_conf.progress_clear_timer = vim.defer_fn(function()
    lsp_conf.progress = ""
    vim.cmd "redrawstatus"
  end, 2750)
end
-- }}}1

local servers = { "clangd", "rust_analyzer" }

local on_attach = function(client, bufnr)
  vim.opt_local.omnifunc = "v:lua.vim.lsp.omnifunc"
  vim.opt_local.signcolumn = "yes"

  vim.cmd(
    "autocmd! CursorHold <buffer> "
      .. "lua vim.lsp.diagnostic.show_line_diagnostics({focusable = false})"
  )

  if client.name == "clangd" then
    kmap("n", "<space>s", "<cmd>ClangdSwitchSourceHeader<cr>")
  end

  kmap("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>")
  kmap("n", "<c-k>", "<cmd>lua vim.lsp.buf.signature_help()<cr>")
  kmap("i", "<c-k>", "<cmd>lua vim.lsp.buf.signature_help()<cr>")

  kmap("n", "<space><space>", "<cmd>Telescope lsp_document_diagnostics<cr>")
  kmap("n", "]<space>", "<cmd>lua vim.lsp.diagnostic.goto_next()<cr>")
  kmap("n", "[<space>", "<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>")

  kmap("n", "<c-]>", "<cmd>lua vim.lsp.buf.definition()<cr>")
  kmap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>")
  kmap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>")
  kmap("n", "<space>t", "<cmd>lua vim.lsp.buf.type_definition()<cr>")
  kmap("n", "<space>i", "<cmd>Telescope lsp_implementations<cr>")
  kmap("n", "<space>r", "<cmd>Telescope lsp_references<cr>")

  kmap("n", "<space>R", "<cmd>lua vim.lsp.buf.rename()<cr>")
  kmap(
    "n",
    "<space>f",
    "<cmd>echo 'Formatting buffer...'<bar>lua vim.lsp.buf.formatting()<cr>"
  )
  kmap(
    "x",
    "<space>f",
    "<esc><cmd>echo 'Formatting selection...'<bar>"
      .. "lua vim.lsp.buf.range_formatting()<cr>"
  )
  kmap("n", "<space>a", "<cmd>Telescope lsp_code_actions<cr>")
  kmap("x", "<space>a", "<esc><cmd>Telescope lsp_range_code_actions<cr>")

  kmap("n", "<space>w", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>")
  kmap("n", "<space>d", "<cmd>Telescope lsp_document_symbols<cr>")
end

for _, s in pairs(servers) do
  lspconfig[s].setup {
    on_attach = on_attach,
    handlers = {
      ["textDocument/hover"] = lsp.with(
        lsp.handlers.hover,
        { border = "single" }
      ),
      ["textDocument/signatureHelp"] = lsp.with(
        lsp.handlers.signature_help,
        { border = "single" }
      ),
      ["textDocument/formatting"] = function(...)
        lsp.handlers["textDocument/formatting"](...)
        echo "Buffer formatted!"
      end,
      ["textDocument/rangeFormatting"] = function(...)
        lsp.handlers["textDocument/rangeFormatting"](...)
        echo "Range formatted!"
      end,
    },
  }
end

vim.cmd [[
  augroup lsp_conf_update_statusline
    autocmd!
    autocmd User LspProgressUpdate lua lsp_conf.update_progress()
    autocmd User LspDiagnosticsChanged redrawstatus!
  augroup END

  highlight default link LspDiagnosticsStlError LspDiagnosticsSignError
  highlight default link LspDiagnosticsStlWarning LspDiagnosticsSignWarning
  highlight default link LspDiagnosticsStlInfo LspDiagnosticsSignInfo

  highlight default link LspDiagnosticsStlNCError LspDiagnosticsStlError
  highlight default link LspDiagnosticsStlNCWarning LspDiagnosticsStlWarning
  highlight default link LspDiagnosticsStlNCInfo LspDiagnosticsStlInfo
]]

return lsp_conf
