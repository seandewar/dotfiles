""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sean Dewar's Autoload Configuration for minpac <https://github.com/seandewar>"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! plugin_conf#minpac#ensure_init() abort
    " assume initialized if we've loaded minpac, which will be the case if it's
    " done via the functions in this autoload script
    if !exists('g:loaded_minpac')
        call plugin_conf#minpac#reload()
    endif
endfunction

function! plugin_conf#minpac#reload() abort
    packadd minpac

    " minpac (self-update)
    " on nvim, install to the data dir over the config dir by default
    call minpac#init({'dir': get(g:, 'minpac_base_dir',
                \ has('nvim') ? stdpath('data') . '/site' : ''),
                \ 'progress_open': 'none'})
    call minpac#add('k-takata/minpac', {'type': 'opt'})

    runtime plugin_list.vim
endfunction
