local cmd = vim.cmd

local util = require "conf.util"
local map = util.map
local t = util.t

local M = {}

cmd [[
  packadd nvim-treesitter
  packadd nvim-treesitter-textobjects
  packadd nvim-gps
]]
local configs = require "nvim-treesitter.configs"
local gps = require "nvim-gps"

--- show tree-sitter context alongside cursor location info
function M.echo_cursor_info()
  cmd(t "normal! g<c-g>")
  if gps.is_available() then
    local context = gps.get_location()
    if context ~= "" then
      cmd("echo '" .. context .. "'")
    end
  end
end

configs.setup {
  ensure_installed = "maintained",
  ignore_install = { "zig" },  -- TODO: remove when zig parser doesn't freeze

  highlight = {
    enable = true,
    additional_vim_regex_highlighting = true, -- so spellchecker ignores code
  },
  incremental_selection = { enable = true },
  -- indent = { enable = true }, -- disabled due to bugs

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

gps.setup {
  icons = {
    ["class-name"] = "[c] ",
    ["function-name"] = "[f] ",
    ["method-name"] = "[m] ",
  },
}

map("n", "g<c-g>", "<cmd>lua require('conf.treesitter').echo_cursor_info()<cr>")

return M
