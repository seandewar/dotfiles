local fn = vim.fn

local servers = {
  "clangd",
  "zls",

  {
    name = "rust_analyzer",
    cmd = fn.executable "rust-analyzer" == 1 and { "rust-analyzer" } or {
      "rustup",
      "run",
      "nightly",
      "rust-analyzer",
    },
    settings = {
      ["rust-analyzer"] = {
        checkOnSave = {
          command = "clippy",
        },
      },
    },
  },

  {
    name = "sumneko_lua",
    cmd = { "lua-language-server" },
    settings = {
      Lua = {
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          maxPreload = 2000,
          preloadFileSize = 1000,
        },
        runtime = {
          version = "LuaJIT",
          path = vim.list_extend(
            vim.split(package.path, ";"),
            { "lua/?.lua", "lua/?/init.lua" }
          ),
        },
        diagnostics = {
          globals = {
            -- (Neo)Vim
            "vim",
            -- Busted
            "after_each",
            "before_each",
            "context",
            "describe",
            "it",
            "setup",
            "teardown",
          },
          disable = { "lowercase-global" },
        },
        telemetry = { enable = false },
      },
    },
  },
}

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
      -- LspAttach needs Nvim 0.8
      if fn.has "nvim-0.8" == 0 then
        require("conf.lsp").attach_buffer {
          buf = vim.api.nvim_get_current_buf(),
        }
      end
      require("conf.lsp").lspconfig_attach_curbuf(client)
    end,
  }
)

for _, config in ipairs(servers) do
  local name
  if type(config) == "string" then
    name = config
    config = {}
  else
    name = config.name
    config.name = nil
  end
  lspconfig[name].setup(config)
end
