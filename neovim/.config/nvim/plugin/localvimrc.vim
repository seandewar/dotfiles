let g:localvimrc_name = ['.lvimrc', '.vim/lvimrc']
let g:localvimrc_sandbox = 0  " It's easy to escape and causes an extra prompt

let g:localvimrc_persistent = 1
let g:localvimrc_persistence_file =
            \ (has('nvim') ? stdpath('data') : $MYVIMRUNTIME)
            \ .. '/localvimrc_persistent'
