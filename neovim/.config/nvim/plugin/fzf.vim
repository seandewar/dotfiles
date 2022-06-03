let g:fzf_history_dir = (has('nvim') ? stdpath('data') : $MYVIMRUNTIME)
            \           .. '/fzf-history'

" Mimic Vim's pum behaviour a lil' (and move the history maps elsewhere)
let $FZF_DEFAULT_OPTS ..= ' --cycle'
             \         .. ' --bind=ctrl-n:down,ctrl-p:up'
             \         .. ' --bind=down:next-history,up:previous-history'

" :GFiles command that falls back to :Files if not in a git repo.
command! -bang -nargs=? GFilesOrFiles silent call system('git rev-parse')
            \| execute (v:shell_error ? 'Files' : 'GFiles') .. '<bang> <args>'

" General mappings
nnoremap <leader>fb <Cmd>Buffers<CR>
nnoremap <leader>f/ <Cmd>BLines<CR>
nnoremap <leader>ff <Cmd>GFilesOrFiles<CR>
nnoremap <leader>fF <Cmd>Files<CR>
nnoremap <leader>fo <Cmd>History<CR>
nnoremap <leader>ft <Cmd>Tags<CR>

" Search file contents with ripgrep
if executable('rg')
    nnoremap <leader>fs <Cmd>Rg<CR>
endif
