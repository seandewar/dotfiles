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
  rev = "main",
  pullmethod = "autostash",
  ["do"] = function()
    if vim.g.loaded_nvim_treesitter ~= nil then
      vim.cmd.TSUpdate()
    end
  end,
})
start("nvim-treesitter/nvim-treesitter-textobjects", {
  rev = "main",
  pullmethod = "autostash",
})

-- Fzf integration
start "ibhagwan/fzf-lua"

-- Firenvim (web browser integration)
opt(
  "glacambre/firenvim",
  { ["do"] = "packadd firenvim | call firenvim#install(0)" }
)
