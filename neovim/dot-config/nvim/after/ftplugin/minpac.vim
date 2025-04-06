" minpac changes 'wrap' after setting the filetype; I don't like that.
execute 'call timer_start(0, {-> win_execute(' win_getid()
            \                                ', ''setlocal wrap<'', '''')})'
