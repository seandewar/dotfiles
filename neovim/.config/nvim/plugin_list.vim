" color schemes
call minpac#add('bluz71/vim-moonfly-colors')

" general plugins
call minpac#add('editorconfig/editorconfig-vim')
call minpac#add('sbdchd/neoformat')
call minpac#add('tpope/vim-commentary')
call minpac#add('tpope/vim-dispatch')
call minpac#add('embear/vim-localvimrc')
call minpac#add('seandewar/vim-qftoggle')
call minpac#add('tpope/vim-repeat')
call minpac#add('tpope/vim-surround')
call minpac#add('tpope/vim-vinegar')

" git integration
call minpac#add('tpope/vim-fugitive')
call minpac#add('tpope/vim-rhubarb')

" filetypes and language support
call minpac#add('rust-lang/rust.vim')

" snippets with integrations
call minpac#add('hrsh7th/vim-vsnip')
call minpac#add('rafamadriz/friendly-snippets')

" Neovim 0.5+ plugins past this point
if !has('nvim-0.5')
    finish
endif

" language server protocol
call minpac#add('neovim/nvim-lspconfig', {'type': 'opt'})

" debug adapter protocol
call minpac#add('mfussenegger/nvim-dap', {'type': 'opt'})

" treesitter
call minpac#add('nvim-treesitter/nvim-treesitter', {'type': 'opt'})
call minpac#add('nvim-treesitter/nvim-treesitter-textobjects', {'type': 'opt'})
call minpac#add('SmiteshP/nvim-gps', {'type': 'opt'})

" telescope fuzzy finder
call minpac#add('nvim-lua/plenary.nvim', {'type': 'opt'})
call minpac#add('nvim-telescope/telescope.nvim', {'type': 'opt'})
call minpac#add('nvim-telescope/telescope-fzy-native.nvim', {'type': 'opt'})
