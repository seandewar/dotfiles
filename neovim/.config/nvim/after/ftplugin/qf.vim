" Only do this once for the current window (not buffer)
if exists('w:did_qf_ftplugin_after')
    finish
endif
let w:did_qf_ftplugin_after = 1

" Open QuickFix window at the bottom of the screen if errors are always to be
" opened in the previous window due to 'uselast' set in 'switchbuf' (as the
" QuickFix window doesn't really relate to the window it's split from)
if index(split(&switchbuf, ','), 'uselast') >= 0
            \ && !getwininfo(win_getid())[0].loclist
    wincmd J
endif
