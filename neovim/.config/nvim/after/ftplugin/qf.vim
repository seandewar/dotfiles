" Only do some of this stuff once for the current window (not buffer)
let s:new_window = !exists('w:did_qf_ftplugin_after')
if s:new_window
    let w:did_qf_ftplugin_after = 1
    setlocal cursorline

    " Open QuickFix window at the bottom of the screen if errors are always to
    " be opened in the previous window due to 'uselast' set in 'switchbuf' (as
    " the QuickFix window doesn't really relate to the window it's split from)
    if index(split(&switchbuf, ','), 'uselast') >= 0
                \ && !getwininfo(win_getid())[0].loclist
        wincmd J
    endif
endif

" Fit the list window to its content, only if the size of the window is the
" default (10) and the number of lines is lesser.
if winheight(win_getid()) == 10 && line('$') < 10
    if !&l:wrap
        " Simple case: no wrapping, so it's just the number of buffer lines (we
        " assume there's no funny stuff like virtual lines).
        let s:new_height = line('$')
    elseif has('nvim')
        " Nvim has a convenient API for us to use here.
        let s:info = nvim_win_text_height(0, {})
        let s:new_height = s:info.all - s:info.fill
    else
        " Complicated case: have to manually calculate this. Boooooo!
        let s:info = getwininfo(win_getid())[0]
        let s:max_width = max([1, s:info.width - s:info.textoff])
        let s:new_height = 0
        for linenr in range(1, line('$'))
            let s:new_height += 1 +
                        \ max([0, virtcol([linenr, '$']) - 2]) / s:max_width
        endfor
    endif

    execute 'resize' min([10, s:new_height])
    " Creating and moving the list window may have caused window sizes to
    " vertically equalize if &ea's set. Will need to do it again after resizing.
    if &equalalways
        vertical wincmd =
    endif
endif

unlet! s:new_window s:new_height s:info s:max_width
