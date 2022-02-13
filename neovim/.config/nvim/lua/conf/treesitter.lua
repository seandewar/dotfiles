local api = vim.api
local fn = vim.fn
local cmd = vim.cmd
local map = vim.keymap.set

local t = require("conf.util").t

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

configs.setup {
  -- NOTE: the install experience on Windows is pretty rough, so just install
  -- parsers that we're likely to want
  ensure_installed = fn.has "win32" == 0 and "maintained" or {
    "c",
    "cmake",
    "cpp",
    "glsl",
    "lua",
    "rust",
    "vim",
    "zig",
  },

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

spellsitter.setup { enable = true }
gps.setup { disable_icons = true }

--- show tree-sitter context alongside cursor location info
local function echo_cursor_context()
  local chunks = { { api.nvim_exec(t "normal! g<C-G>", true) } }
  if gps.is_available() then
    local context = gps.get_location()
    if context ~= "" then
      vim.list_extend(
        chunks,
        { { "\n" }, { "Context:", "Directory" }, { " " .. context } }
      )
    end
  end
  api.nvim_echo(chunks, false, {})
end

map("n", "g<C-G>", echo_cursor_context)

return M
