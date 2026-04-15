return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = {
    ".luarc.json",
    ".luarc.jsonc",
  },
  workspace_required = false,

  on_init = function(client, _)
    -- Only assume we're editing Nvim Lua scripts when not using a workspace.
    if #(client.workspace_folders or {}) > 0 then
      return
    end

    client.settings = vim.tbl_deep_extend("force", client.settings, {
      Lua = {
        runtime = {
          version = "LuaJIT",
        },
        workspace = {
          checkThirdParty = "Disable",
          library = {
            vim.env.VIMRUNTIME,
          },
        },
      },
    })
  end,
} --[[@as vim.lsp.Config]]
