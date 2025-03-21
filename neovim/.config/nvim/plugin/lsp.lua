local api = vim.api
local keymap = vim.keymap
local lsp = vim.lsp

local util = require "conf.util"

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

local new_capability_change_handler = function(orig_handler)
  return function(err, params, ctx)
    local ret = orig_handler(err, params, ctx)
    require("conf.lsp").setup_attached_buffers(ctx.client_id)
    return ret
  end
end
lsp.handlers["client/registerCapability"] =
  new_capability_change_handler(lsp.handlers["client/registerCapability"])
lsp.handlers["client/unregisterCapability"] =
  new_capability_change_handler(lsp.handlers["client/unregisterCapability"])

-- These mappings, like the Nvim defaults, mostly override "gr" for LSP stuff.
keymap.set(
  "n",
  "grt",
  lsp.buf.type_definition,
  { desc = "LSP Type Definition" }
)

keymap.set({ "n", "x" }, "grf", function()
  lsp.buf.format { async = true }
end, {
  desc = "LSP Format",
})

keymap.set("n", "grr", function()
  if vim.g.loaded_fzf_lua ~= nil then
    require("fzf-lua").lsp_references()
  else
    lsp.buf.references()
  end
end, { desc = "LSP References" })

keymap.set("n", "grw", function()
  if vim.g.loaded_fzf_lua ~= nil then
    require("fzf-lua").lsp_live_workspace_symbols()
  else
    lsp.buf.workspace_symbol()
  end
end, { desc = "LSP Workspace Symbols" })

keymap.set("n", "gO", function()
  if vim.g.loaded_fzf_lua ~= nil then
    require("fzf-lua").lsp_document_symbols()
  else
    lsp.buf.document_symbol()
  end
end, { desc = "LSP Document Symbols" })

keymap.set("n", "grh", function()
  if #lsp.get_clients { bufnr = 0, method = "textDocument/inlayHint" } == 0 then
    util.echo {
      {
        "No language servers attached to this buffer support inlay hints",
        "WarningMsg",
      },
    }
    return
  end

  local enable = not lsp.inlay_hint.is_enabled { bufnr = 0 }
  lsp.inlay_hint.enable(enable, { bufnr = 0 })
  util.echo("Buffer inlay hints " .. (enable and "enabled" or "disabled"))
end, { desc = "LSP Toggle Buffer Inlay Hints" })

keymap.set("n", "<C-S>", lsp.buf.signature_help, {
  desc = "LSP Signature Help",
})
