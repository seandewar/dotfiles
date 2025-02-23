local keymap = vim.keymap

local fzf = require "fzf-lua"

fzf.setup {
  -- We need to make sure the --bind happens after --history, so we can't use
  -- the fzf_opts or fzf keys to map Up/Down or override CTRL-N/P.
  fzf_args = ("--history=" .. vim.fn.stdpath "data" .. "/fzf_history")
    .. " --bind=ctrl-n:down,ctrl-p:up"
    .. " --bind=down:next-history,up:previous-history",
  fzf_opts = { ["--cycle"] = "" },

  winopts = {
    backdrop = 100,
    preview = {
      default = "cat",
      wrap = true,
      winopts = { number = false },
    },
  },

  defaults = { file_icons = false },

  lsp = {
    symbols = { symbol_style = 3 },
  },

  previewers = {
    builtin = {
      -- Regex highlighting is faster for the initial parse, which makes it
      -- better suited than tree-sitter for the previewer, though less accurate.
      treesitter = { enabled = false },
    },
    cat = { args = "" }, -- Disable the default-enabled line numbers.
  },

  fzf_colors = {
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
  },
}
fzf.register_ui_select()

keymap.set("n", "<Leader>ff", "<Cmd>FzfLua files<CR>")
keymap.set("n", "<Leader>fb", "<Cmd>FzfLua buffers<CR>")
keymap.set("n", "<Leader>f/", "<Cmd>FzfLua blines<CR>")
keymap.set("n", "<Leader>fo", "<Cmd>FzfLua oldfiles<CR>")
keymap.set("n", "<Leader>fg", "<Cmd>FzfLua live_grep<CR>")
keymap.set("n", "<Leader>fG", "<Cmd>FzfLua grep_cword<CR>")
keymap.set("n", "<Leader>ft", "<Cmd>FzfLua tags<CR>")

keymap.set("n", "<Leader>gf", "<Cmd>FzfLua git_files<CR>")

keymap.set("n", "z=", "<Cmd>FzfLua spell_suggest<CR>")
