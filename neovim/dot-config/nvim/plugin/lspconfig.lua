local api = vim.api
local fn = vim.fn
local fs = vim.fs

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
  })

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
    if vim.system({ "cargo", "clippy", "--version" }):wait().code == 0 then
      config.settings =
        { ["rust-analyzer"] = { check = { command = "clippy" } } }
    end
  end,
})

setup("lua_ls", {
  on_init = function(client)
    local rt_paths = vim.tbl_map(function(p)
      return fn.resolve(p)
    end, api.nvim_list_runtime_paths())
    -- Don't configure the environment for Nvim if the workspace doesn't contain
    -- any directories within the runtimepath.
    if
      not vim.iter(client.workspace_folders or {}):any(function(wf)
        local wfp = fn.resolve(wf.name)
        return vim.iter(rt_paths):any(function(rtp)
          return fs.relpath(rtp, wfp) ~= nil
        end)
      end)
    then
      return
    end

    client.settings = vim.tbl_deep_extend("force", client.settings, {
      Lua = {
        runtime = {
          version = "LuaJIT",
        },
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME,
          },
        },
      },
    })
  end,
})
