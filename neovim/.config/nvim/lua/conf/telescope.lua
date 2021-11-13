if vim.fn.has "nvim-0.5.1" == 0 then
  return
end

local cmd = vim.cmd
local map = require("conf.util").map

cmd [[
  packadd plenary.nvim
  packadd telescope.nvim
  packadd telescope-fzy-native.nvim
]]
local telescope = require "telescope"
local actions = require "telescope.actions"

telescope.load_extension "fzy_native"
telescope.setup {
  defaults = {
    mappings = {
      i = {
        -- somewhat mimic command-line mode behaviour here
        ["<Down>"] = actions.cycle_history_next,
        ["<Up>"] = actions.cycle_history_prev,
        ["<S-Down>"] = actions.cycle_history_next,
        ["<S-Up>"] = actions.cycle_history_prev,
      },
    },
  },
}

map("n", "z=", "<cmd>Telescope spell_suggest<cr>")

map("n", "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<cr>")
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>")
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>")
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
