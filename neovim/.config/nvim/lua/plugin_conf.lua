--------------------------------------------------------------------------------
-- Sean Dewar's Neovim 0.5+ Lua Plugin Config <https://github.com/seandewar>  --
--------------------------------------------------------------------------------
-- File Locals {{{1
local api, fn = vim.api, vim.fn
local cmd, kmap = vim.cmd, vim.api.nvim_set_keymap

-- General Plugin Settings {{{1
-- telescope.nvim {{{2
cmd "packadd telescope.nvim"
cmd "packadd plenary.nvim"
cmd "packadd popup.nvim"

-- nvim-treesitter {{{2
cmd "packadd nvim-treesitter"
cmd "packadd nvim-treesitter-textobjects"

require"nvim-treesitter.configs".setup {
    ensure_installed = "maintained",

    highlight = {
        enable = true,
        additional_vim_regex_highlighting = true -- so spellchecker ignores code
    },
    incremental_selection = {enable = true},
    -- indent = {enable = true}, -- NOTE: disabled due to bugs

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

-- nvim-dap {{{2
cmd "packadd nvim-dap"
local dap = require "dap"

dap.adapters["lldb-vscode"] = {
    name = "lldb-vscode",
    type = "executable",
    command = "lldb-vscode",
    attach = {pidProperty = "pid", pidSelect = "ask"},
    env = {LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = "YES"}
}

-- Mappings {{{1
-- telescope.nvim {{{2
-- FIXME: re-enable the commented-out mega-slow/meh finders until they're fixed
kmap("n", "<leader>fb", "<cmd>Telescope buffers<cr>", {silent = true})
kmap("n", "<leader>ff",
     "<cmd>lua require'telescope.builtin'.find_files { hidden = true }<cr>",
     {silent = true})
-- kmap("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", {silent = true})
kmap("n", "<leader>fo", "<cmd>Telescope oldfiles<cr>", {silent = true})

kmap("n", "<leader>f/", "<cmd>Telescope current_buffer_fuzzy_find<cr>",
     {silent = true})
kmap("n", "<leader>fc", "<cmd>Telescope quickfix<cr>", {silent = true})
kmap("n", "<leader>fl", "<cmd>Telescope loclist<cr>", {silent = true})

-- kmap("n", "<leader>ft", "<cmd>Telescope tags<cr>", {silent = true})
kmap("n", "<leader>fs", "<cmd>Telescope treesitter<cr>", {silent = true})

-- nvim-dap {{{2
kmap("n", "<leader>dd", "<cmd>lua require'dap'.repl.open()<cr>", {silent = true})
kmap("n", "<f5>", "<cmd>lua require'dap'.continue()<cr>", {silent = true})
kmap("n", "<c-f5>", "<cmd>lua require'dap'.run_last()<cr>", {silent = true})

kmap("n", "<f9>", "<cmd>lua require'dap'.toggle_breakpoint()<cr>",
     {silent = true})

kmap("n", "<c-f9>", "<cmd>lua require'dap'.set_breakpoint(" ..
         "vim.fn.input('Breakpoint condition: '))<cr>", {silent = true})

kmap("n", "<leader>dl", "<cmd>lua require'dap'.set_breakpoint(nil, nil, " ..
         "vim.fn.input('Log point message: '))<cr>", {silent = true})

kmap("n", "<f10>", "<cmd>lua require'dap'.step_over()<cr>", {silent = true})
kmap("n", "<f11>", "<cmd>lua require'dap'.step_into()<cr>", {silent = true})
kmap("n", "<f12>", "<cmd>lua require'dap'.step_out()<cr>", {silent = true})
