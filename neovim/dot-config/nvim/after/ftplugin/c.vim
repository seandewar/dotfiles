if executable('clang-format')
    " Send whole buffer, but specify the range so the formatter has context.
    let &l:formatexpr = "v:lua.require'conf.formatting'.cmd_formatexpr(
            \ ['clang-format',
            \ '--fail-on-incomplete-format',
            \ '--assume-filename=''' .. expand('%:p') .. '''',
            \ '--lines=' .. v:lnum .. ':' .. (v:lnum + v:count - 1)],
            \ 1, line('$'))"

    let b:undo_ftplugin = get(b:, 'undo_ftplugin', '') ..
            \ "\nsetlocal formatexpr<"
endif
