""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sean Dewar's Autoload Configuration for minpac <https://github.com/seandewar>"
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! plugin_conf#minpac#reload() abort
    packadd minpac

    " minpac (self-update)
    " on nvim, install to the data dir over the config dir by default
    call minpac#init({'dir': get(g:, 'minpac_base_dir',
                \ has('nvim') ? stdpath('data') . '/site' : '')})
    call minpac#add('k-takata/minpac', {'type': 'opt'})

    runtime plugin_list.vim
endfunction
