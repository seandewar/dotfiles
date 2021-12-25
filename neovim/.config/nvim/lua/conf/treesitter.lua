local api = vim.api
local cmd = vim.cmd

local util = require "conf.util"
local map = util.map
local t = util.t

local M = {}

cmd [[
  packadd nvim-treesitter
  packadd nvim-treesitter-textobjects
  packadd spellsitter.nvim
  packadd nvim-gps
]]
local configs = require "nvim-treesitter.configs"
local spellsitter = require "spellsitter"
local gps = require "nvim-gps"

--- show tree-sitter context alongside cursor location info
function M.echo_cursor_info()
  cmd(t "normal! g<C-G>")
  if gps.is_available() then
    local context = gps.get_location()
    if context ~= "" then
      cmd("echo 'Context:' '" .. context .. "'")
    end
  end
end

configs.setup {
  ensure_installed = "maintained",

  highlight = {
    enable = true,
    -- TODO: some parsers can be slow for big files & vim hls are inaccurate
    disable = function(lang, bufnr)
      return lang == "vim" or api.nvim_buf_line_count(bufnr) > 4000
    end,
  },
  -- indent = { enable = true }, -- TODO: disabled due to bugs

  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "<CR>",
      scope_incremental = "<CR>",
      node_incremental = "<Tab>",
      node_decremental = "<S-Tab>",
    },
  },

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

spellsitter.setup {
  enable = true,
  spellchecker = "vimfn",
}

gps.setup { disable_icons = true }

map("n", "g<C-G>", "<Cmd>lua require('conf.treesitter').echo_cursor_info()<CR>")

return M
