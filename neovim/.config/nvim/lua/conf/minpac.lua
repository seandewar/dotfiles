-- Helper functions {{{1
local function start(url, opts)
  opts = vim.tbl_extend("force", { type = "start" }, opts or {})
  vim.fn["minpac#add"](url, opts)
end

local function opt(url, opts)
  opts = vim.tbl_extend("force", { type = "opt" }, opts or {})
  vim.fn["minpac#add"](url, opts)
end
-- }}}

-- vim.ui.input, vim.ui.select
start "stevearc/dressing.nvim"

-- Tree-sitter
start("nvim-treesitter/nvim-treesitter", {
  ["do"] = function()
    if vim.g.loaded_nvim_treesitter ~= nil then
      vim.cmd "TSUpdate"
    end
  end,
})
start "nvim-treesitter/nvim-treesitter-textobjects"
start "lewis6991/spellsitter.nvim"
opt "SmiteshP/nvim-gps"

-- Language server protocol
start "neovim/nvim-lspconfig"

-- Firenvim (web browser integration)
opt(
  "glacambre/firenvim",
  { ["do"] = "packadd firenvim | call firenvim#install(0)" }
)
