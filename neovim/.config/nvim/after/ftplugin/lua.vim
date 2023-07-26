setlocal shiftwidth=2

" Nvim has a built-in Lua reference manual and other stuff.
if has('nvim')
    setlocal keywordprg=:help
endif

call conf#ft#undo_ftplugin('setlocal shiftwidth< keywordprg<')
