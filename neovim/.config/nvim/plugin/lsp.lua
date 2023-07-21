local api = vim.api
local lsp = vim.lsp
local map = vim.keymap.set

local util = require "conf.util"
local echo = util.echo
local echomsg = util.echomsg

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
    echomsg {
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
})
lsp.handlers["textDocument/rangeFormatting"] = lsp.with(formatting_handler, {
  name = "Range",
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

map("n", "<Space>h", function()
  -- Handle toggling ourselves, as there's no public API for checking its
  -- current state to use for echoing (it's not always obvious whether or not
  -- the hints are on; e.g: if there are no hints reported).
  if
    vim.b.conf_inlay_hint_on
    or #lsp.get_clients { bufnr = 0, method = "textDocument/inlayHint" } > 0
  then
    local enable = not vim.b.conf_inlay_hint_on
    lsp.inlay_hint(0, enable)
    vim.b.conf_inlay_hint_on = enable
    echo("Buffer inlay hints " .. (enable and "enabled" or "disabled"))
  else
    echo {
      {
        "No language servers attached to this buffer support inlay hints",
        "WarningMsg",
      },
    }
  end
end, { desc = "LSP Toggle Buffer Inlay Hints" })

map({ "n", "i" }, "<C-K>", lsp.buf.signature_help, {
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
