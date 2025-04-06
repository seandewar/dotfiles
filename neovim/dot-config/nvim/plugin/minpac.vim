" NOTE: use :execute so that expand('<sfile>') results in this script's path
execute 'command! -bar PackUpdate '
            \ .. 'call conf#minpac#ensure_init() | call minpac#update("", '
            \ .. '#{do: "source ' .. expand('<sfile>') .. ' | packloadall!"})'

command! -bar PackClean call conf#minpac#ensure_init() | call minpac#clean()
command! -bar PackStatus call conf#minpac#ensure_init() | call minpac#status()
