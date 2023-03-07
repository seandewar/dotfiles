local fn = vim.fn
local lsp = vim.lsp

local lspconfig = require "lspconfig"

lspconfig.util.default_config = vim.tbl_extend(
  "force",
  lspconfig.util.default_config,
  {
    -- Usually don't want LSP when using firenvim (as we'll usually edit single
    -- files, not projects, and not all servers support single files very well)
    autostart = vim.g.started_by_firenvim == nil,

    flags = { debounce_text_changes = 150 },
    on_attach = function(client)
      require("conf.lsp").lspconfig_attach_curbuf(client)
    end,
  }
)

lspconfig.clangd.setup {}
lspconfig.zls.setup {}

lspconfig.rust_analyzer.setup {
  cmd = fn.executable "rust-analyzer" == 1 and { "rust-analyzer" } or {
    "rustup",
    "run",
    "stable",
    "rust-analyzer",
  },
  settings = {
    ["rust-analyzer"] = {
      check = {
        command = "clippy",
      },
    },
  },
  handlers = {
    ["window/showMessage"] = function(err, result, ctx, config)
      -- Ignore the "overly long loop turn" message shown by nightly builds.
      if not result.message:match "^overly long loop turn" then
        lsp.handlers["window/showMessage"](err, result, ctx, config)
      end
    end,
  },
}

-- TODO: Sure, I have quite a few runtime files and maybe I should be more
-- choosy with which ones I index, but lua_ls is still too slow (and kicks my
-- CPU's butt) when indexing, so disable for now.
-- lspconfig.lua_ls.setup {
--   settings = {
--     Lua = {
--       workspace = {
--         library = vim.api.nvim_get_runtime_file("", true),
--       },
--       runtime = {
--         version = "LuaJIT",
--         path = vim.list_extend(
--           vim.split(package.path, ";"),
--           { "lua/?.lua", "lua/?/init.lua" }
--         ),
--       },
--       diagnostics = {
--         globals = {
--           -- (Neo)vim
--           "vim",
--           -- Busted
--           "after_each",
--           "before_each",
--           "context",
--           "describe",
--           "it",
--           "pending",
--           "setup",
--           "teardown",
--         },
--         disable = { "lowercase-global" },
--       },
--       telemetry = { enable = false },
--     },
--   },
-- }
