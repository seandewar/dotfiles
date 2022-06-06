local api = vim.api
local fn = vim.fn
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

local function response_select_handler(err, result, ctx, config)
  if err then
    echo {
      { "Failed to get " .. config.name .. ":", "WarningMsg" },
      { " " .. err.message },
    }
    return
  end
  if not result or vim.tbl_isempty(result) then
    echo("No " .. config.name .. " found")
    return
  end

  local items = lsp.util.symbols_to_items(result, ctx.bufnr)
  vim.ui.select(items, {
    prompt = config.prompt,
    format_item = function(item)
      return ("%s  %s(%s)"):format(
        item.text,
        (" "):rep(math.max(0, 38 - #item.text)),
        fn.fnamemodify(item.filename, ":~:.")
      )
    end,
  }, function(choice, _)
    if choice then
      vim.cmd(
        ([[edit +call\ cursor(%d,%d)|normal!\ zz %s]]):format(
          choice.lnum,
          choice.col,
          choice.filename
        )
      )
    end
  end)
end

lsp.handlers["textDocument/documentSymbol"] =
  lsp.with(response_select_handler, {
    name = "Document symbols",
    prompt = "Document symbol:",
  })
lsp.handlers["workspace/symbol"] = lsp.with(response_select_handler, {
  name = "Workspace symbols",
  prompt = "Workspace symbol:",
})

-- LspAttach, LspDetach needs Nvim 0.8
if fn.has "nvim-0.8" == 1 then
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
end

map("n", "<Space>t", lsp.buf.type_definition, { desc = "LSP Type Definition" })
map("n", "<Space>i", lsp.buf.implementation, { desc = "LSP Implementations" })
map("n", "<Space>r", lsp.buf.references, { desc = "LSP References" })
map("n", "<Space>R", lsp.buf.rename, { desc = "LSP Rename" })
map("n", "<Space>a", lsp.buf.code_action, { desc = "LSP Code Action" })
map("x", "<Space>f", "<Esc><Cmd>lua vim.lsp.buf.range_formatting()<CR>")
map("x", "<Space>a", "<Esc><Cmd>lua vim.lsp.buf.range_code_action()<CR>")

map({ "n", "i" }, "<C-K>", lsp.buf.signature_help, {
  desc = "LSP Signature Help",
})

map("n", "<Space>d", lsp.buf.document_symbol, {
  desc = "LSP Document Symbols",
})

map("n", "<Space>w", function()
  local supported = false
  for _, client in ipairs(lsp.get_active_clients { bufnr = 0 }) do
    if client.server_capabilities.workspaceSymbolProvider then
      supported = true
      break
    end
  end
  if not supported then
    echo { { "No attached servers support Workspace symbols", "ErrorMsg" } }
    return
  end

  vim.ui.input({ prompt = "Workspace symbols query:" }, function(input)
    if input then
      lsp.buf.workspace_symbol(input)
    end
  end)
end, {
  desc = "LSP Query Workspace Symbols",
})

map("n", "<Space>W", function()
  lsp.buf.workspace_symbol ""
end, {
  desc = "LSP Workspace Symbols",
})

map("n", "<Space>f", function()
  lsp.buf.format { async = true }
end, {
  desc = "LSP Formatting",
})
