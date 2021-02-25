" color schemes
call minpac#add('bluz71/vim-moonfly-colors', {'type': 'opt'})

" general plugins
call minpac#add('editorconfig/editorconfig-vim')
call minpac#add('sbdchd/neoformat')
call minpac#add('tpope/vim-commentary')
call minpac#add('tpope/vim-dispatch')
call minpac#add('tpope/vim-fugitive')
call minpac#add('embear/vim-localvimrc')
call minpac#add('seandewar/vim-qftoggle')
call minpac#add('tpope/vim-repeat')
call minpac#add('tpope/vim-surround')
call minpac#add('tpope/vim-vinegar')

" lsp
call minpac#add('prabirshrestha/vim-lsp', {'type': 'opt'})
call minpac#add('mattn/vim-lsp-settings', {'type': 'opt'})

" snippets with integrations
call minpac#add('hrsh7th/vim-vsnip')
call minpac#add('hrsh7th/vim-vsnip-integ', {'type': 'opt'})

" neovim 0.5+ plugins
if has('nvim-0.5')
    call minpac#add('nvim-treesitter/nvim-treesitter', {'type': 'opt'})
    call minpac#add('nvim-treesitter/nvim-treesitter-textobjects',
                \ {'type': 'opt'})
endif
