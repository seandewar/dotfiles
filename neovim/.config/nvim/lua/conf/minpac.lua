local fn = vim.fn

local function add(url, opts)
  opts = vim.tbl_extend("force", { type = "opt" }, opts or {})
  fn["minpac#add"](url, opts)
end

-- tree-sitter
add("nvim-treesitter/nvim-treesitter", { ["do"] = "TSUpdate" })
add "nvim-treesitter/nvim-treesitter-textobjects"
add "lewis6991/spellsitter.nvim"
add "SmiteshP/nvim-gps"

-- telescope
add "nvim-lua/plenary.nvim"
add "nvim-telescope/telescope.nvim"
add "nvim-telescope/telescope-ui-select.nvim"
add "nvim-telescope/telescope-fzy-native.nvim"

-- language server protocol
add "neovim/nvim-lspconfig"

-- firenvim (web browser integration)
add(
  "glacambre/firenvim",
  { ["do"] = "packadd firenvim | call firenvim#install(0)" }
)
