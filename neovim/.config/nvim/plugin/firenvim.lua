if not vim.g.started_by_firenvim then
  return
end

local cmd = vim.cmd
local fn = vim.fn
local map = vim.keymap.set

cmd.packadd "firenvim"
cmd.runtime "ginit.vim"

vim.g.firenvim_config = {
  localSettings = {
    [".*"] = {
      -- Only trigger firenvim when <C-E> is pressed in the browser (or whatever
      -- the key is set to in the extension's settings).
      takeover = "never",
    },
  },
}

map("n", "<Esc><Esc>", fn["firenvim#focus_page"])
map("n", "<C-Z>", fn["firenvim#hide_frame"])
