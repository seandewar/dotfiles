" color schemes
call minpac#add('bluz71/vim-moonfly-colors')

" general plugins
call minpac#add('github/copilot.vim')
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
call minpac#add('ziglang/zig.vim')

" snippets with integrations
call minpac#add('hrsh7th/vim-vsnip')
call minpac#add('rafamadriz/friendly-snippets')

" Neovim 0.5+ Plugins {{{1
if has('nvim-0.5')
    lua package.loaded["conf.plugin_list"] = nil; require 'conf.plugin_list'
end
