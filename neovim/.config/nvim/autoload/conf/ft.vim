function! s:UndoFt(type, cmd_list) abort
    let value = get(b:, 'undo_' .. a:type, '')
    let b:['undo_' .. a:type] = value
                \ .. (match(value, '|\s*$') == -1 ? ' | ' : '')
                \ .. join(a:cmd_list, ' | ')
endfunction

function! conf#ft#undo_ftplugin(...) abort
    call s:UndoFt('ftplugin', a:000)
endfunction

function! conf#ft#undo_indent(...) abort
    call s:UndoFt('indent', a:000)
endfunction
