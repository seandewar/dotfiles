function! conf#tabedit_dir(dir) abort
    execute 'tabedit ' .. a:dir .. ' | tcd ' .. a:dir
endfunction
