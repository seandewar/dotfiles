local fn = vim.fn

-- Helper functions {{{1
local function start(url, opts)
  opts = vim.tbl_extend("force", { type = "start" }, opts or {})
  fn["minpac#add"](url, opts)
end

local function opt(url, opts)
  opts = vim.tbl_extend("force", { type = "opt" }, opts or {})
  fn["minpac#add"](url, opts)
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

-- Fzf integration (fzf-lua doesn't work on Windows)
if fn.has "win32" == 0 then
  start "ibhagwan/fzf-lua"
end

-- Language server protocol
start "neovim/nvim-lspconfig"

-- Firenvim (web browser integration)
opt(
  "glacambre/firenvim",
  { ["do"] = "packadd firenvim | call firenvim#install(0)" }
)
