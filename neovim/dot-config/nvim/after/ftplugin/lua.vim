setlocal shiftwidth=2
let b:undo_ftplugin = get(b:, 'undo_ftplugin', '') .. "\nsetlocal shiftwidth<"

" Nvim has a built-in Lua reference manual and other stuff.
if has('nvim')
    setlocal keywordprg=:help
    let b:undo_ftplugin = get(b:, 'undo_ftplugin', '') ..
                \ "\nsetlocal keywordprg<"
endif
