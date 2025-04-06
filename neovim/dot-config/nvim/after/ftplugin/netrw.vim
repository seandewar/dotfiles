nnoremap <silent> <buffer> <C-L> <Cmd>nohlsearch<CR><Plug>NetrwRefresh

let b:undo_ftplugin = get(b:, 'undo_ftplugin', '') .. "\nunmap <buffer> <C-L>"
