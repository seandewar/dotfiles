local api = vim.api
local map = vim.keymap.set

local t = require("conf.util").t

local configs = require "nvim-treesitter.configs"
local spellsitter = require "spellsitter"
local gps

configs.setup {
  -- Install only a minimal set of parsers that I'm likely to want.
  -- Other parsers can be installed when wanted with :TSInstall
  ensure_installed = {
    "c",
    "cmake",
    "cpp",
    "lua",
    "rust",
    "vim",
  },

  highlight = {
    enable = true,
    disable = function(lang, _)
      return lang == "vim" -- TODO: disabled due to inaccurate highlights
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

--- Show tree-sitter context with cursor location info
local function echo_cursor_context()
  if package.loaded["nvim-gps"] == nil then
    vim.cmd "packadd nvim-gps"
    gps = require "nvim-gps"
    gps.setup { disable_icons = true }
  end

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
