local fs = vim.fs
local uv = vim.uv

return {
  --- @param client vim.lsp.Client
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
    -- vim.uv (luv) meta files are vendored since Nvim 0.12.
    if vim.fn.has "nvim-0.12" == 0 then
      --- @diagnostic disable-next-line: undefined-field
      table.insert(client.settings.Lua.workspace.library, "${3rd}/luv/library")
    end
  end,
}
