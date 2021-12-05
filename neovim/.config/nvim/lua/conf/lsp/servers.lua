local api = vim.api
local fn = vim.fn

local M = {
  "clangd",
  "hls",
  "zls",
  {
    name = "rust_analyzer",
    cmd = fn.executable "rust-analyzer" == 1 and { "rust-analyzer" } or {
      "rustup",
      "run",
      "nightly",
      "rust-analyzer",
    },
  },
  {
    name = "sumneko_lua",
    cmd = { "lua-language-server" },
    settings = {
      Lua = {
        workspace = {
          library = api.nvim_get_runtime_file("", true),
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

return M
