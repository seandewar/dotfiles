setlocal shiftwidth=2
setlocal keywordprg=:help  " Nvim has built-in Lua reference manuals.

let b:undo_ftplugin = get(b:, 'undo_ftplugin', '')
            \ .. "\nsetlocal shiftwidth< keywordprg<"

if executable('stylua')
    " Send whole buffer, but specify the range so the formatter has context.
    let &l:formatexpr = "v:lua.require'conf.formatting'.cmd_formatexpr(
            \ ['stylua',
            \ '--search-parent-directories',
            \ '--stdin-filepath', expand('%:p'),
            \ '--range-start', max([0, line2byte(v:lnum) - 1]),
            \ '--range-end', max([0, line2byte(v:lnum + v:count) - 2]),
            \ '-'],
            \ 1, line('$'))"

    let b:undo_ftplugin = get(b:, 'undo_ftplugin', '')
            \ .. "\nsetlocal formatexpr<"
endif
