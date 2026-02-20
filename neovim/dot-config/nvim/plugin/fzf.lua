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
      wrap = true,
      winopts = { number = false },
    },
  },

  defaults = {
    file_icons = false,
    follow = true,
  },

  buffers = {
    previewer = "builtin",
  },
  blines = {
    previewer = "builtin",
  },
  diagnostics = {
    diag_source = true,
  },
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

  fzf_colors = true,
}
fzf.register_ui_select()

keymap.set("n", "<Leader>f/", "<Cmd>FzfLua blines<CR>")
keymap.set("n", "<Leader>fG", "<Cmd>FzfLua grep_cword<CR>")
keymap.set("n", "<Leader>fb", "<Cmd>FzfLua buffers<CR>")
keymap.set("n", "<Leader>ff", "<Cmd>FzfLua files<CR>")
keymap.set("n", "<Leader>fg", "<Cmd>FzfLua live_grep<CR>")
keymap.set("n", "<Leader>fj", "<Cmd>FzfLua jumps<CR>")
keymap.set("n", "<Leader>fc", "<Cmd>FzfLua changes<CR>")
keymap.set("n", "<Leader>fo", "<Cmd>FzfLua oldfiles<CR>")
keymap.set("n", "<Leader>fr", "<Cmd>FzfLua resume<CR>")
keymap.set("n", "<Leader>ft", "<Cmd>FzfLua tags<CR>")
keymap.set("n", "<Leader>fT", "<Cmd>FzfLua tagstack<CR>")
keymap.set("n", "<Leader>fu", "<Cmd>FzfLua undotree<CR>")

keymap.set("n", "<Leader>gf", "<Cmd>FzfLua git_files<CR>")

keymap.set("n", "z=", "<Cmd>FzfLua spell_suggest<CR>")
