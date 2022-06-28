local api = vim.api
local keymap = vim.keymap

local fzf = require "fzf-lua"

fzf.setup {
  -- We need to make sure the --bind happens after --history, so we can't use
  -- the fzf_opts or fzf keys to map Up/Down or override CTRL-N/P.
  fzf_args = ("--history=" .. vim.fn.stdpath "data" .. "/fzf_history")
    .. " --bind=ctrl-n:down,ctrl-p:up"
    .. " --bind=down:next-history,up:previous-history",

  fzf_opts = { ["--cycle"] = "" },
  nbsp = "\xc2\xa0",

  lsp = {
    icons = {
      ["Error"] = { icon = "E", color = "red" },
      ["Warning"] = { icon = "W", color = "yellow" },
      ["Information"] = { icon = "I", color = "blue" },
      ["Hint"] = { icon = "H", color = "magenta" },
    },
  },
}

fzf.register_ui_select()

local function setup_colors()
  fzf.setup {
    fzf_colors = vim.tbl_extend("keep", vim.g.fzf_colors or {}, {
      ["fg"] = { "fg", "CursorLine" },
      ["bg"] = { "bg", "Normal" },
      ["hl"] = { "fg", "Comment" },
      ["fg+"] = { "fg", "Normal" },
      ["bg+"] = { "bg", "CursorLine" },
      ["hl+"] = { "fg", "Statement" },
      ["info"] = { "fg", "PreProc" },
      ["prompt"] = { "fg", "Conditional" },
      ["pointer"] = { "fg", "Exception" },
      ["marker"] = { "fg", "Keyword" },
      ["spinner"] = { "fg", "Label" },
      ["header"] = { "fg", "Comment" },
      ["gutter"] = { "bg", "Normal" },
    }),
  }
end

api.nvim_create_autocmd("ColorScheme", {
  group = api.nvim_create_augroup("conf_fzf_colors", {}),
  callback = setup_colors,
})
setup_colors()

keymap.set("n", "<Leader>f<Space>", "<Cmd>FzfLua<CR>")
keymap.set("n", "<Leader>ff", "<Cmd>FzfLua files<CR>")
keymap.set("n", "<Leader>fb", "<Cmd>FzfLua buffers<CR>")
keymap.set("n", "<Leader>f/", "<Cmd>FzfLua blines<CR>")
keymap.set("n", "<Leader>fo", "<Cmd>FzfLua oldfiles<CR>")
keymap.set("n", "<Leader>fg", "<Cmd>FzfLua live_grep<CR>")
keymap.set("n", "<Leader>ft", "<Cmd>FzfLua tags<CR>")

keymap.set("n", "<Leader>gf", "<Cmd>FzfLua git_files<CR>")
