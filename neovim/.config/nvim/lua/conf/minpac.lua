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

-- Tree-sitter
start("nvim-treesitter/nvim-treesitter", {
  ["do"] = function()
    if vim.g.loaded_nvim_treesitter ~= nil then
      vim.cmd.TSUpdate()
    end
  end,
})
start "nvim-treesitter/nvim-treesitter-textobjects"
start "nvim-treesitter/playground"
opt "SmiteshP/nvim-gps"

-- Fzf integration
start "ibhagwan/fzf-lua"

-- Language server protocol
start "neovim/nvim-lspconfig"

-- Firenvim (web browser integration)
opt(
  "glacambre/firenvim",
  { ["do"] = "packadd firenvim | call firenvim#install(0)" }
)
