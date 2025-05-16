command! -bar PackUpdate
            \ execute 'lua require"conf.minpac"' | call minpac#update()
command! -bar PackClean
            \ execute 'lua require"conf.minpac"' | call minpac#clean()
command! -bar PackStatus
            \ execute 'lua require"conf.minpac"' | call minpac#status()
