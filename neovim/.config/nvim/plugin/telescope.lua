local cmd = vim.cmd
local map = vim.keymap.set

cmd [[
  packadd plenary.nvim
  packadd telescope.nvim
  packadd telescope-ui-select.nvim
  packadd telescope-fzy-native.nvim
]]
local telescope = require "telescope"
local actions = require "telescope.actions"

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

-- Failure to load extensions shouldn't abort running the rest of this script.
local function safe_load_extension(name)
  local ok, error = pcall(telescope.load_extension, name)
  if not ok then
    vim.api.nvim_err_writeln(
      ('Error loading telescope extension "%s": %s'):format(name, error)
    )
  end
end

safe_load_extension "ui-select"
safe_load_extension "fzy_native"

map("n", "z=", "<Cmd>Telescope spell_suggest<CR>")

map("n", "<Leader>f/", "<Cmd>Telescope current_buffer_fuzzy_find<CR>")
map("n", "<Leader>fb", "<Cmd>Telescope buffers<CR>")
map("n", "<Leader>ff", "<Cmd>Telescope find_files<CR>")
map(
  "n",
  "<Leader>fF",
  "<Cmd>Telescope find_files hidden=true no_ignore=true<CR>"
)
map("n", "<Leader>fg", "<Cmd>Telescope live_grep<CR>")
map("n", "<Leader>fo", "<Cmd>Telescope oldfiles<CR>")
map("n", "<Leader>fc", "<Cmd>Telescope quickfix<CR>")
map("n", "<Leader>fl", "<Cmd>Telescope loclist<CR>")
map("n", "<Leader>ft", "<Cmd>Telescope tags<CR>")
map("n", "<Leader>fs", "<Cmd>Telescope treesitter<CR>")

-- vim.diagnostic
map("n", "<Space><Space>", "<Cmd>Telescope diagnostics bufnr=0<CR>")
map("n", "<Space><C-Space>", "<Cmd>Telescope diagnostics<CR>")

-- git
map("n", "<Leader>gB", "<Cmd>Telescope git_branches<CR>")
