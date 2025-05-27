local fn = vim.fn
local fs = vim.fs

-- Setup {{{1
vim.cmd.packadd "minpac"
if not vim.g.loaded_minpac then
  error("minpac is not installed!", 0)
end

fn["minpac#init"] {
  dir = fs.joinpath(fn.stdpath "data", "site"),
  progress_open = "none",
  status_auto = true,
}

local function start(url, opts)
  opts = vim.tbl_extend("force", { type = "start" }, opts or {})
  fn["minpac#add"](url, opts)
end

local function opt(url, opts)
  opts = vim.tbl_extend("force", { type = "opt" }, opts or {})
  fn["minpac#add"](url, opts)
end
-- }}}

opt "k-takata/minpac"

-- Colour scheme
start("seandewar/paragon.vim", { rev = "next", pullmethod = "autostash" })

start "tpope/vim-dispatch"
start "tpope/vim-repeat"
start "tpope/vim-surround"
start "tpope/vim-vinegar"

-- Git integration
start "tpope/vim-fugitive"
start "tpope/vim-rhubarb"

-- Fuzzy finding via fzf
start "ibhagwan/fzf-lua"

-- Up-to-date filetype support for Zig
start "ziglang/zig.vim"

-- Tree-sitter
start("nvim-treesitter/nvim-treesitter", {
  rev = "main",
  ["do"] = function()
    if not vim.g.loaded_nvim_treesitter then
      return
    end
    local nts = require "nvim-treesitter"

    -- Ensure a minimal set of parsers are installed.
    -- Others may be installed on-demand via ":TSInstall".
    nts.install {
      -- These parsers are bundled with Nvim itself, and need to be updated by
      -- nvim-treesitter so its newer queries don't throw errors when using the
      -- older bundled parsers:
      "c",
      "lua",
      "markdown",
      "markdown_inline",
      "query",
      "vim",
      "vimdoc",

      -- Extra parsers not bundled with Nvim:
      "cpp",
      "comment",
    }

    -- Update all installed parsers, including those manually ":TSInstall"ed.
    nts.update()
  end,
})
start("nvim-treesitter/nvim-treesitter-textobjects", {
  rev = "main",
  pullmethod = "autostash",
})

-- Web browser integration via firenvim
opt("glacambre/firenvim", {
  ["do"] = "packadd firenvim | call firenvim#install(0)",
})

-- vim: fdm=marker fdl=0
