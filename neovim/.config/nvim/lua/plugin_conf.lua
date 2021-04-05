--------------------------------------------------------------------------------
-- Sean Dewar's Neovim 0.5+ Lua Plugin Config <https://github.com/seandewar>  --
--------------------------------------------------------------------------------

-- File Locals {{{1
local api, fn = vim.api, vim.fn
local cmd, keymap = vim.cmd, vim.api.nvim_set_keymap

-- General Plugin Settings {{{1
-- telescope.nvim {{{2
cmd "packadd telescope.nvim"
cmd "packadd plenary.nvim"
cmd "packadd popup.nvim"

-- nvim-treesitter {{{2
cmd "packadd nvim-treesitter"
cmd "packadd nvim-treesitter-textobjects"

require "nvim-treesitter.configs".setup {
  ensure_installed = "maintained",

  -- these parsers require the tree-sitter CLI, which may not be installed
  -- TODO: remove extra Windows-only ignores when they're fixed upstream
  ignore_install = vim.list_extend(
    fn.executable("tree-sitter") == 0 and {
      "erlang", "ocamllex", "gdscript", "devicetree", "ledger", "supercollider",
      "nix"
    } or {},
    fn.has("win32") == 1 and {
      "ocaml", "ocaml_interface", "typescript", "tsx"
    } or {}
  ),
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true -- so spellchecker ignores code
  },
  incremental_selection = {enable = true},
  -- indent = {enable = true}, -- NOTE: disabled due to bugs

  -- the following don't define default mappings, hence:
  textobjects = {
    select = {
      enable = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner"
      }
    },
    move = {
      enable = true,
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = "@class.outer"
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer"
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer"
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer"
      }
    }
  }
}

-- Mappings {{{1
-- telescope.nvim {{{2
keymap("n", "<leader>fb", "<cmd>Telescope buffers<cr>", {silent = true})
keymap("n", "<leader>ff", "<cmd>Telescope find_files<cr>", {silent = true})
keymap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", {silent = true})
keymap("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", {silent = true})

keymap("n", "<leader>fc", "<cmd>Telescope quickfix<cr>", {silent = true})
keymap("n", "<leader>fl", "<cmd>Telescope loclist<cr>", {silent = true})

keymap("n", "<leader>ft", "<cmd>Telescope tags<cr>", {silent = true})
keymap("n", "<leader>fs", "<cmd>Telescope treesitter<cr>", {silent = true})
