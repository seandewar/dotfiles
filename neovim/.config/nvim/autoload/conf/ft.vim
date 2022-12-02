function! s:UndoFt(type, cmd_list) abort
    let cmd = join(a:cmd_list, '|')
    let undo = get(b:, 'undo_' .. a:type, '')
    if undo =~? '^\s*$'
        " b:undo_* is empty, we can just set it directly.
        let undo = cmd
    else
        " Some plugins (looking at you, zig.vim) have commands at the end of
        " b:undo_* that do not accept trailing bars. To work around this,
        " :execute the previous value of b:undo_* so we can use a bar.
        let undo = printf("execute'%s'|%s",
                    \     substitute(undo, "'", "''", 'g'), cmd)
    endif
    let b:['undo_' .. a:type] = undo
endfunction

function! conf#ft#undo_ftplugin(...) abort
    call s:UndoFt('ftplugin', a:000)
endfunction

function! conf#ft#undo_indent(...) abort
    call s:UndoFt('indent', a:000)
endfunction
