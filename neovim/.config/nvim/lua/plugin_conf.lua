--------------------------------------------------------------------------------
-- Sean Dewar's Neovim 0.5+ Lua Plugin Config <https://github.com/seandewar>  --
--------------------------------------------------------------------------------
local api, cmd = vim.api, vim.cmd

local map = function(mode, lhs, rhs, opts)
  opts = vim.tbl_extend("keep", opts or {}, { silent = true, noremap = true })
  api.nvim_set_keymap(mode, lhs, rhs, opts)
end

local t = function(str)
  return api.nvim_replace_termcodes(str, true, true, true)
end

-- Global, as this file isn't usually require()'d (allows reloading)
plugin_conf = {}

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

-- nvim-dap {{{2
cmd "packadd nvim-dap"

require("dap").adapters["lldb-vscode"] = {
  name = "lldb-vscode",
  type = "executable",
  command = "lldb-vscode",
  attach = { pidProperty = "pid", pidSelect = "ask" },
  env = { LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = "YES" },
}

-- Language Server Protocol {{{2
cmd "packadd nvim-lspconfig"
package.loaded.lsp_conf = nil
require "lsp_conf"

-- Mappings {{{1
-- nvim-gps {{{2
-- show tree-sitter context alongside cursor location info
plugin_conf.echo_cursor_info = function()
  vim.cmd(t "normal! g<c-g>")
  local gps = require "nvim-gps"
  if gps.is_available() then
    local context = gps.get_location()
    if context ~= "" then
      vim.cmd("echo '" .. context .. "'")
    end
  end
end

map("n", "g<c-g>", "<cmd>call v:lua.plugin_conf.echo_cursor_info()<cr>")

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

-- nvim-dap {{{2
map("n", "<leader>dd", "<cmd>lua require'dap'.repl.open()<cr>")
map("n", "<f5>", "<cmd>lua require'dap'.continue()<cr>")
map("n", "<c-f5>", "<cmd>lua require'dap'.run_last()<cr>")

map("n", "<f9>", "<cmd>lua require'dap'.toggle_breakpoint()<cr>")
map(
  "n",
  "<c-f9>",
  "<cmd>lua require'dap'.set_breakpoint("
    .. "vim.fn.input('Breakpoint condition: '))<cr>"
)
map(
  "n",
  "<leader>dl",
  "<cmd>lua require'dap'.set_breakpoint(nil, nil, "
    .. "vim.fn.input('Log point message: '))<cr>"
)

map("n", "<f10>", "<cmd>lua require'dap'.step_over()<cr>")
map("n", "<f11>", "<cmd>lua require'dap'.step_into()<cr>")
map("n", "<f12>", "<cmd>lua require'dap'.step_out()<cr>")
-- }}}2

return plugin_conf
