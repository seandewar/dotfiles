local fn = vim.fn
local lsp = vim.lsp

local lspconfig = require "lspconfig"

lspconfig.util.default_config =
  vim.tbl_extend("force", lspconfig.util.default_config, {
    -- Usually don't want LSP when using firenvim (as we'll usually edit single
    -- files, not projects, and not all servers support single files very well)
    autostart = vim.g.started_by_firenvim == nil,
    flags = { debounce_text_changes = 150 },
    on_attach = function(client)
      require("conf.lsp").lspconfig_attach_curbuf(client)
    end,
  })

-- TODO: Mitigate bugs from the LibUV bump that may cause Nvim to hang on exit
-- or for job spawning to fail from having too many polled files.
local capabilities = lsp.protocol.make_client_capabilities()
capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = false
lspconfig.util.default_config.capabilities = capabilities

local function setup(config_name, config)
  config = config or {}
  -- It is recommended that the default `on_new_config` is also called when
  -- overriding it, so this handles that.
  if config.on_new_config then
    local default_fn =
      lspconfig[config_name].document_config.default_config.on_new_config
    if default_fn then
      config.on_new_config = function(...)
        default_fn(...)
        config.on_new_config(...)
      end
    end
  end

  lspconfig[config_name].setup(config)
end

setup "clangd"
setup "zls"

setup("rust_analyzer", {
  -- Use `on_new_config` to avoid doing this logic at startup.
  on_new_config = function(config, _)
    fn.system { "cargo", "clippy", "--version" }
    if vim.v.shell_error == 0 then
      config.settings =
        { ["rust-analyzer"] = { check = { command = "clippy" } } }
    end
  end,
})

-- TODO: Sure, I have quite a few runtime files and maybe I should be more
-- choosy with which ones I index, but lua_ls is still too slow (and kicks my
-- CPU's butt) when indexing, so disable for now.
-- setup("lua_ls", {
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
-- })
