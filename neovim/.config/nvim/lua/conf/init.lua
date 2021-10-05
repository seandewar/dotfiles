local api = vim.api
local cmd = vim.cmd
local fn = vim.fn

local util = require "conf.util"
local map = util.map

local M = {}

-- General Plugin Settings {{{1
-- telescope.nvim {{{2
cmd "packadd plenary.nvim"
cmd "packadd telescope.nvim"
cmd "packadd telescope-fzy-native.nvim"

require("telescope").load_extension "fzy_native"

-- nvim-treesitter {{{2
cmd "packadd nvim-treesitter"
cmd "packadd nvim-treesitter-textobjects"

require("nvim-treesitter.configs").setup {
  ensure_installed = "maintained",

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true, -- so spellchecker ignores code
  },
  incremental_selection = { enable = true },
  -- indent = {enable = true}, -- NOTE: disabled due to bugs

  textobjects = {
    select = {
      enable = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
    move = {
      enable = true,
      goto_next_start = {
        ["]m"] = "@function.outer",
        ["]]"] = "@class.outer",
      },
      goto_next_end = {
        ["]M"] = "@function.outer",
        ["]["] = "@class.outer",
      },
      goto_previous_start = {
        ["[m"] = "@function.outer",
        ["[["] = "@class.outer",
      },
      goto_previous_end = {
        ["[M"] = "@function.outer",
        ["[]"] = "@class.outer",
      },
    },
  },
}

-- nvim-gps {{{2
cmd "packadd nvim-gps"

require("nvim-gps").setup {
  icons = {
    ["class-name"] = "[c] ",
    ["function-name"] = "[f] ",
    ["method-name"] = "[m] ",
  },
}

-- Diagnostics and LSP {{{2
-- require v0.5.1 over v0.5 for vim.diagnostic and anonymous sourcing fixes
if fn.has("nvim-0.5.1") == 1 then
  require "conf.diagnostic"
  cmd "packadd nvim-lspconfig"
  require "conf.lsp"
end

-- Mappings {{{1
-- nvim-gps {{{2
-- show tree-sitter context alongside cursor location info
function M.echo_cursor_info()
  vim.cmd(util.t "normal! g<c-g>")
  local gps = require "nvim-gps"
  if gps.is_available() then
    local context = gps.get_location()
    if context ~= "" then
      vim.cmd("echo '" .. context .. "'")
    end
  end
end

map("n", "g<c-g>", "<cmd>lua require('conf.plugins').echo_cursor_info()<cr>")

-- telescope.nvim {{{2
map("n", "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>")

map("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
map("n", "<leader>ff", "<cmd>Telescope find_files hidden=true<cr>")
map(
  "n",
  "<leader>fF",
  "<cmd>Telescope find_files hidden=true no_ignore=true<cr>"
)
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>")
map("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>")
map("n", "<leader>fc", "<cmd>Telescope quickfix<cr>")
map("n", "<leader>fl", "<cmd>Telescope loclist<cr>")
map("n", "<leader>ft", "<cmd>Telescope tags<cr>")
map("n", "<leader>fs", "<cmd>Telescope treesitter<cr>")

-- git-specific mappings & vim-fugitive overrides
map("n", "<leader>gB", "<cmd>Telescope git_branches<cr>")
-- }}}2

return M
