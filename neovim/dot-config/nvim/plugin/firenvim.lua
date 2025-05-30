if not vim.g.started_by_firenvim then
  return
end

local cmd = vim.cmd
local fn = vim.fn
local keymap = vim.keymap

vim.filetype.add {
  pattern = {
    -- Assume C++, as that's what I usually use on Leetcode.
    [".*/leetcode%.com_[^/]*"] = "cpp",
  },
}

cmd.packadd { "firenvim", bang = true }
cmd.runtime "ginit.vim"

vim.g.firenvim_config = {
  localSettings = {
    [".*"] = {
      cmdline = "neovim",
      -- Only trigger firenvim when <C-E> is pressed in the browser (or whatever
      -- the key is set to in the extension's settings).
      takeover = "never",
    },
  },
}

vim.o.cmdheight = 0

keymap.set("n", "<Esc><Esc>", fn["firenvim#focus_page"])
keymap.set("n", "<C-Z>", fn["firenvim#hide_frame"])
