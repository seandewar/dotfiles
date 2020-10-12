function! pack#LoadMinpac() abort
    packadd minpac
    call minpac#init()

    " minpac (self-update)
    call minpac#add('k-takata/minpac', {'type': 'opt'})

    " color schemes
    call minpac#add('tomasiser/vim-code-dark',
                \ {'package_name': 'colors', 'type': 'opt'})
    call minpac#add('bluz71/vim-moonfly-colors',
                \ {'package_name': 'colors', 'type': 'opt'})

    " general plugins
    call minpac#add('dense-analysis/ale', {'package_name': 'general'})
    call minpac#add('SirVer/ultisnips', {'package_name': 'general'})
    call minpac#add('tpope/vim-commentary', {'package_name': 'general'})
    call minpac#add('justinmk/vim-dirvish', {'package_name': 'general'})
    call minpac#add('tpope/vim-dispatch', {'package_name': 'general'})
    call minpac#add('derekwyatt/vim-fswitch', {'package_name': 'general'})
    call minpac#add('tpope/vim-fugitive', {'package_name': 'general'})
    call minpac#add('seandewar/vim-qftoggle', {'package_name': 'general'})
    call minpac#add('tpope/vim-repeat', {'package_name': 'general'})
    call minpac#add('tpope/vim-surround', {'package_name': 'general'})
endfunction
