function! conf#minpac#ensure_init() abort
    if exists('s:initialized') | return | endif
    packadd minpac
    if !exists('g:loaded_minpac')
        echohl ErrorMsg | echo 'minpac is not installed!' | echohl None
        return
    endif

    " minpac self-updating; on Nvim, install to the site directory by default
    let dir = has('nvim') ? stdpath('data') .. '/site' : ''
    call minpac#init(#{dir: dir, progress_open: 'none', status_auto: 1})
    call minpac#add('k-takata/minpac', #{type: 'opt'})

    " Colour scheme
    call minpac#add('seandewar/paragon.vim')

    " General plugins
    call minpac#add('sbdchd/neoformat')
    call minpac#add('tpope/vim-dispatch')
    call minpac#add('tpope/vim-repeat')
    call minpac#add('tpope/vim-sleuth')
    call minpac#add('tpope/vim-surround')
    call minpac#add('tpope/vim-vinegar')

    " Git integration
    call minpac#add('tpope/vim-fugitive')
    call minpac#add('tpope/vim-rhubarb')

    " Extra filetypes and language support
    call minpac#add('rust-lang/rust.vim')
    call minpac#add('ziglang/zig.vim')

    " Vim plugins
    if !has('nvim')
        " Nvim has built-in commenting.
        call minpac#add('tpope/vim-commentary')
    endif

    " Nvim plugins
    if has('nvim')
        lua require "conf.minpac"
    endif
    let s:initialized = 1
endfunction
