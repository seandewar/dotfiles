local fn = vim.fn

local configs = require "nvim-treesitter.configs"

configs.setup {
  -- Install a minimal set of parsers.
  -- Others can be installed on-demand with :TSInstall
  --
  -- C, Lua, Vim and Vimdoc parsers are bundled with Nvim, but are more
  -- up-to-date via nvim-treesitter. (Also some distros don't package them,
  -- annoyingly)
  ensure_installed = {
    "c",
    -- "comment", -- TODO: is slow.
    "cpp",
    "help",
    "lua",
    "vim",
  },

  highlight = {
    enable = true,
    -- Disabled for now due to inaccurate highlights.
    disable = { "vim", "help" },
  },

  incremental_selection = {
    enable = true,
    disable = function()
      return fn.getcmdwintype() ~= ""
    end,
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
      lookahead = true,
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
