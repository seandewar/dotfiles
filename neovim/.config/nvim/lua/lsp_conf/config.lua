local api, fn = vim.api, vim.fn

local function sumneko_lua_config()
  local bin_path = fn.exepath "lua-language-server"
  if bin_path == "" then
    return nil
  end

  local root_path = fn.fnamemodify(bin_path, ":h:h:h")
  local runtime_path = vim.split(package.path, ";")
  runtime_path[#runtime_path + 1] = "lua/?.lua"
  runtime_path[#runtime_path + 1] = "lua/?/init.lua"

  return {
    name = "sumneko_lua",
    cmd = { bin_path, "-E", root_path .. "/main.lua" },
    settings = {
      Lua = {
        runtime = { version = "LuaJIT", path = runtime_path },
        diagnostics = { globals = { "vim" } },
        workspace = { library = api.nvim_get_runtime_file("", true) },
        telemetry = { enable = false },
      },
    },
  }
end

local M = {
  config = {
    "clangd",
    "rust_analyzer",
    sumneko_lua_config(),
  },
}

return M
