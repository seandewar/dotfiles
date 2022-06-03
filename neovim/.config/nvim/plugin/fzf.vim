let g:fzf_history_dir = (has('nvim') ? stdpath('data') : $MYVIMRUNTIME)
            \           .. '/fzf-history'

" Mimic Vim's pum behaviour a lil' (and move the history mapping somewhere else)
let $FZF_DEFAULT_OPTS ..= ' --cycle'
             \         .. ' --bind=ctrl-n:down,ctrl-p:up'
             \         .. ' --bind=down:next-history,up:previous-history'

" General mappings
nnoremap <leader>fb <Cmd>Buffers<CR>
nnoremap <leader>f/ <Cmd>BLines<CR>
nnoremap <leader>ff <Cmd>Files<CR>
nnoremap <leader>fo <Cmd>History<CR>
nnoremap <leader>ft <Cmd>Tags<CR>

" Search file contents
if executable('rg')
    nnoremap <leader>fs <Cmd>Rg<CR>
elseif executable('ag')
    nnoremap <leader>fs <Cmd>Ag<CR>
endif

" Git
nnoremap <leader>fg <Cmd>GFiles<CR>
