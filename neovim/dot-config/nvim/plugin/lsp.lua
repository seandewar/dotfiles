local api = vim.api
local keymap = vim.keymap
local lsp = vim.lsp

local enabled_configs = {
  "clangd",
  "lua_ls",
  "rust_analyzer",
  "zls",
}

lsp.config("*", {
  root_markers = { ".git" },
})

-- Usually don't want LSP when using firenvim.
if not vim.g.started_by_firenvim then
  lsp.enable(enabled_configs)
end

api.nvim_create_user_command("LspOn", function(_)
  lsp.enable(enabled_configs, true)
end, { bar = true, desc = "Enable LSP autostart" })
api.nvim_create_user_command("LspOff", function(_)
  lsp.enable(enabled_configs, false)
end, { bar = true, desc = "Disable LSP autostart" })

api.nvim_create_user_command("LspStart", function(args)
  require("conf.lsp").start_command(args, enabled_configs)
end, {
  nargs = "*",
  bar = true,
  --- @param arg string
  complete = function(arg)
    -- No way to get the list of all vim.lsp.config'd things (_enabled_configs
    -- only has the vim.lsp.enabled ones); just use the usual enable list.
    return vim.tbl_filter(function(name)
      return arg == name:sub(1, #arg)
    end, enabled_configs)
  end,
  desc = "Attach language servers to current buffer",
})

api.nvim_create_user_command("LspStop", function(args)
  require("conf.lsp").stop_command(args)
end, {
  nargs = "*",
  bang = true,
  bar = true,
  --- @param arg string
  complete = function(arg)
    return vim
      .iter(lsp.get_clients { bufnr = 0 })
      :map(function(client)
        return client.name
      end)
      :filter(function(name)
        return arg == name:sub(1, #arg)
      end)
      :totable()
  end,
  desc = "Detach language servers from current buffer",
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

local function document_symbols()
  if vim.g.loaded_fzf_lua ~= nil then
    require("fzf-lua").lsp_document_symbols()
  else
    lsp.buf.document_symbol()
  end
end
-- gO is the Nvim default, but an ftplugin may have overriden it; map grd too.
keymap.set("n", "grd", document_symbols, { desc = "LSP Document Symbols" })
keymap.set("n", "gO", document_symbols, { desc = "LSP Document Symbols" })

keymap.set("n", "grh", function()
  local util = require "conf.util"
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
