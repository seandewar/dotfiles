local api = vim.api
local lsp = vim.lsp
local map = vim.keymap.set

local util = require "conf.util"
local echo = util.echo

local attach_group = api.nvim_create_augroup("conf_lsp_attach_detach", {})
api.nvim_create_autocmd("LspAttach", {
  group = attach_group,
  callback = function(args)
    require("conf.lsp").attach_buffer(args)
  end,
})
api.nvim_create_autocmd("LspDetach", {
  group = attach_group,
  callback = function(args)
    require("conf.lsp").detach_buffer(args)
  end,
})

map("n", "<Space>h", function()
  if #lsp.get_clients { bufnr = 0, method = "textDocument/inlayHint" } == 0 then
    echo {
      {
        "No language servers attached to this buffer support inlay hints",
        "WarningMsg",
      },
    }
    return
  end

  local enable = not lsp.inlay_hint.is_enabled { bufnr = 0 }
  lsp.inlay_hint.enable(enable, { bufnr = 0 })
  echo("Buffer inlay hints " .. (enable and "enabled" or "disabled"))
end, { desc = "LSP Toggle Buffer Inlay Hints" })

map({ "n", "i" }, "<C-K>", function()
  lsp.buf.signature_help { border = "single" }
end, {
  desc = "LSP Signature Help",
})

map("n", "<Space>t", lsp.buf.type_definition, { desc = "LSP Type Definition" })
map("n", "<Space>i", lsp.buf.implementation, { desc = "LSP Implementations" })
map("n", "<Space>R", lsp.buf.rename, { desc = "LSP Rename" })
map({ "n", "x" }, "<Space>a", lsp.buf.code_action, { desc = "LSP Code Action" })
map({ "n", "x" }, "<Space>f", function()
  lsp.buf.format { async = true }
end, {
  desc = "LSP Format",
})

map("n", "<Space>r", function()
  if vim.g.loaded_fzf_lua ~= nil then
    require("fzf-lua").lsp_references()
  else
    lsp.buf.references()
  end
end, { desc = "LSP References" })
map("n", "<Space>d", function()
  if vim.g.loaded_fzf_lua ~= nil then
    require("fzf-lua").lsp_document_symbols()
  else
    lsp.buf.document_symbol()
  end
end, { desc = "LSP Document Symbols" })
map("n", "<Space>w", function()
  if vim.g.loaded_fzf_lua ~= nil then
    require("fzf-lua").lsp_live_workspace_symbols()
  else
    lsp.buf.workspace_symbol()
  end
end, { desc = "LSP Workspace Symbols" })
