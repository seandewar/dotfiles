local fn = vim.fn

local function add(url, opts)
  opts = vim.tbl_extend("force", { type = "opt" }, opts or {})
  fn["minpac#add"](url, opts)
end

-- tree-sitter
add("nvim-treesitter/nvim-treesitter", { ["do"] = "TSUpdate" })
add "nvim-treesitter/nvim-treesitter-textobjects"
add "SmiteshP/nvim-gps"

-- telescope
if fn.has "nvim-0.5.1" == 1 then
  add "nvim-lua/plenary.nvim"
  add "nvim-telescope/telescope.nvim"
  add "nvim-telescope/telescope-ui-select.nvim"
  add "nvim-telescope/telescope-fzy-native.nvim"
end

-- language server protocol
if fn.has "nvim-0.6" == 1 then
  add "neovim/nvim-lspconfig"
end
