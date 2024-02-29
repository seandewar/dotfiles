local api = vim.api
local fn = vim.fn
local lsp = vim.lsp

local lspconfig = require "lspconfig"

-- Usually don't want LSP when using firenvim (as we'll usually edit single
-- files, not projects, and not all servers support single files very well)
local autostart = vim.g.started_by_firenvim == nil

api.nvim_create_autocmd({ "BufReadPost", "FileType" }, {
  group = api.nvim_create_augroup("conf_lspconfig_autostart", {}),
  callback = function()
    if autostart then
      vim.cmd.LspStart()
    end
  end,
})

local function set_autostart(enabled, bang)
  autostart = enabled
  require("conf.util").echo(
    "LSP autostart " .. (enabled and "enabled" or "disabled")
  )
  if bang then
    vim.cmd[enabled and "LspStart" or "LspStop"]()
  end
end

api.nvim_create_user_command("LspAutoOn", function(args)
  set_autostart(true, args.bang)
end, { bar = true, bang = true, desc = "Enable LSP autostart" })

api.nvim_create_user_command("LspAutoOff", function(args)
  set_autostart(false, args.bang)
end, { bar = true, bang = true, desc = "Disable LSP autostart" })

api.nvim_create_user_command("LspAutoToggle", function(args)
  set_autostart(not autostart, args.bang)
end, { bar = true, bang = true, desc = "Toggle LSP autostart" })

lspconfig.util.default_config =
  vim.tbl_extend("force", lspconfig.util.default_config, {
    autostart = false, -- Handle this ourselves.
    flags = { debounce_text_changes = 150 },

    on_attach = function(client)
      require("conf.lsp").lspconfig_attach_curbuf(client)
    end,
  })

-- Disable file watching to workaround current performance issues.
-- TODO: re-enable when it performs better.
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
  -- Using `on_new_config` to avoid doing this logic at Nvim's startup.
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
