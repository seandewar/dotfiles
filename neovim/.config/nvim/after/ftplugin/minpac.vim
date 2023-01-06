" minpac changes 'wrap' after setting the filetype; I don't like that.
let s:win = win_getid() " cba to :unlet this after.
call timer_start(0, {-> win_execute(s:win, 'setlocal wrap<', '')})
