local fn = vim.fn

local configs = require "nvim-treesitter.configs"

configs.setup {
  -- Install a minimal set of parsers.
  -- Others can be installed on-demand with :TSInstall
  ensure_installed = {
    -- Following parsers are bundled with Nvim 0.10 itself, and need to be
    -- updated by nvim-treesitter so that nvim-treesitter's newer queries do not
    -- throw errors with the older Nvim parsers:
    "bash",
    "c",
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "query",
    "vim",
    "vimdoc",

    -- These are extra parsers not bundled with Nvim:
    -- "comment", -- TODO: is slow.
    "cpp",
  },

  highlight = {
    enable = true,
    -- Disabled for now due to inaccurate highlights.
    disable = { "vim" },
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
