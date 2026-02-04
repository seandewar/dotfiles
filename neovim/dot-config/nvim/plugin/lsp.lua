local api = vim.api
local keymap = vim.keymap
local log = vim.log
local lsp = vim.lsp

if not vim.g.started_by_firenvim then
  lsp.enable {
    "clangd",
    "lua_ls",
    "rust_analyzer",
    "zls",
  }
end

lsp.config("*", {
  workspace_required = true,
})

-- Preferring a Vim script command so split modifiers are respected.
api.nvim_create_user_command(
  "LspLog",
  "<mods> split `=v:lua.vim.lsp.get_log_path()`",
  { bar = true, desc = "Open LSP log file" }
)

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

lsp.codelens.enable()

-- These mappings, like the Nvim defaults, mostly override "gr" for LSP stuff.
-- (Many are set to use fzf-lua handlers instead)
keymap.set({ "n", "x" }, "grf", function()
  lsp.buf.format { async = true }
end, {
  desc = "LSP Format",
})

keymap.set("n", "grr", function()
  require("fzf-lua").lsp_references()
end, { desc = "LSP References" })

keymap.set("n", "grw", function()
  require("fzf-lua").lsp_live_workspace_symbols()
end, { desc = "LSP Workspace Symbols" })

local function document_symbols()
  require("fzf-lua").lsp_document_symbols()
end
keymap.set("n", "gO", document_symbols, { desc = "LSP Document Symbols" })
keymap.set("n", "grd", document_symbols, { desc = "LSP Document Symbols" })

keymap.set("n", "grl", lsp.codelens.run, { desc = "LSP Run Code Lens" })

keymap.set("n", "<C-S>", lsp.buf.signature_help, {
  desc = "LSP Signature Help",
})

keymap.set("n", "grh", function()
  if #lsp.get_clients { bufnr = 0, method = "textDocument/inlayHint" } == 0 then
    vim.notify(
      "No clients attached to this buffer support inlay hints",
      log.levels.WARN
    )
    return
  end

  local enable = not lsp.inlay_hint.is_enabled { bufnr = 0 }
  lsp.inlay_hint.enable(enable, { bufnr = 0 })
  vim.cmd.redrawstatus { bang = true }
end, { desc = "LSP Toggle Buffer Inlay Hints" })
