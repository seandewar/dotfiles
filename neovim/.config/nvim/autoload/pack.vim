function! pack#LoadMinpac() abort
    packadd minpac

    " NOTE: empty 'dir' causes minpac to default to first entry in 'packpath'
    call minpac#init({'dir': get(g:, 'minpac_base_dir', '')})

    " minpac (self-update)
    call minpac#add('k-takata/minpac', {'type': 'opt'})

    " color schemes
    call minpac#add('tomasiser/vim-code-dark', {'type': 'opt'})
    call minpac#add('bluz71/vim-moonfly-colors', {'type': 'opt'})

    " general plugins
    call minpac#add('dense-analysis/ale')
    call minpac#add('tpope/vim-commentary')
    call minpac#add('justinmk/vim-dirvish')
    call minpac#add('tpope/vim-dispatch')
    call minpac#add('derekwyatt/vim-fswitch')
    call minpac#add('tpope/vim-fugitive')
    call minpac#add('seandewar/vim-qftoggle')
    call minpac#add('tpope/vim-repeat')
    call minpac#add('tpope/vim-surround')
    call minpac#add('SirVer/ultisnips')
endfunction
