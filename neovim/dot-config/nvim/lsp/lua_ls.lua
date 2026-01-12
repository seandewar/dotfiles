local fs = vim.fs
local uv = vim.uv

return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
  },

  on_init = function(client, _)
    -- Configure for Nvim if there's no top-level luarc file in the workspace.
    if
      vim.iter(client.workspace_folders or {}):any(function(wf)
        return uv.fs_stat(fs.joinpath(wf.name, ".luarc.json")) ~= nil
          or uv.fs_stat(fs.joinpath(wf.name, ".luarc.jsonc")) ~= nil
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
} --[[@as vim.lsp.Config]]
