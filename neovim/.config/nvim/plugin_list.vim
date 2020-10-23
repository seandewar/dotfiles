" color schemes
call minpac#add('tomasiser/vim-code-dark', {'type': 'opt'})
call minpac#add('bluz71/vim-moonfly-colors', {'type': 'opt'})

" general plugins
call minpac#add('dense-analysis/ale')
call minpac#add('editorconfig/editorconfig-vim')
call minpac#add('tpope/vim-commentary')
call minpac#add('justinmk/vim-dirvish')
call minpac#add('tpope/vim-dispatch')
call minpac#add('derekwyatt/vim-fswitch')
call minpac#add('tpope/vim-fugitive')
call minpac#add('seandewar/vim-qftoggle')
call minpac#add('tpope/vim-repeat')
call minpac#add('tpope/vim-surround')
call minpac#add('SirVer/ultisnips')

" neovim 0.5+ plugins
if has('nvim-0.5')
    call minpac#add('nvim-treesitter/nvim-treesitter', {'type': 'opt'})
    call minpac#add('nvim-treesitter/nvim-treesitter-textobjects',
                \ {'type': 'opt'})
endif
