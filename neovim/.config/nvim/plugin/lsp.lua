local api = vim.api
local lsp = vim.lsp
local map = vim.keymap.set

local util = require "conf.util"
local echo = util.echo

-- NOTE: handlers is a metatable, so we can't tbl_extend directly.
lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, {
  border = "single",
})
lsp.handlers["textDocument/signatureHelp"] = lsp.with(
  lsp.handlers.signature_help,
  { border = "single" }
)

local function formatting_handler(err, result, ctx, config)
  if err then
    echo {
      { config.name .. " format failed:", "WarningMsg" },
      { " " .. err.message },
    }
    return
  end
  if not result then
    echo(config.name .. " format complete; no changes")
    return
  end

  local client = lsp.get_client_by_id(ctx.client_id)
  lsp.util.apply_text_edits(result, ctx.bufnr, client.offset_encoding)
  echo(config.name .. " format complete")
end

lsp.handlers["textDocument/formatting"] = lsp.with(formatting_handler, {
  name = "Buffer",
  request = "textDocument/formatting",
})
lsp.handlers["textDocument/rangeFormatting"] = lsp.with(formatting_handler, {
  name = "Range",
  request = "textDocument/rangeFormatting",
})

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

map("n", "<Space>t", lsp.buf.type_definition, { desc = "LSP Type Definition" })
map("n", "<Space>i", lsp.buf.implementation, { desc = "LSP Implementations" })
map("n", "<Space>R", lsp.buf.rename, { desc = "LSP Rename" })
map("n", "<Space>a", lsp.buf.code_action, { desc = "LSP Code Action" })
map("x", "<Space>f", "<Esc><Cmd>lua vim.lsp.buf.range_formatting()<CR>")
map("x", "<Space>a", "<Esc><Cmd>lua vim.lsp.buf.range_code_action()<CR>")

map({ "n", "i" }, "<C-K>", lsp.buf.signature_help, {
  desc = "LSP Signature Help",
})
map("n", "<Space>f", function()
  lsp.buf.format { async = true }
end, {
  desc = "LSP Formatting",
})

map("n", "<Space>r", "<Cmd>FzfLua lsp_references<CR>")
map("n", "<Space>d", "<Cmd>FzfLua lsp_document_symbols<CR>")
map("n", "<Space>w", "<Cmd>FzfLua lsp_live_workspace_symbols<CR>")
