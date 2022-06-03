let g:fzf_history_dir = (has('nvim') ? stdpath('data') : $MYVIMRUNTIME)
            \           .. '/fzf-history'

" Mimic Vim's pum behaviour a lil' (and move the history maps elsewhere)
let $FZF_DEFAULT_OPTS ..= ' --cycle'
            \         .. ' --bind=ctrl-n:down,ctrl-p:up'
            \         .. ' --bind=down:next-history,up:previous-history'

" :GFiles command that falls back to :Files if not in a git repo.
command! -bang -nargs=* GFilesOrFiles silent call system('git rev-parse')
            \| execute (v:shell_error ? 'Files' : 'GFiles') .. '<bang> <args>'

" :LiveRg uses ripgrep, but takes a regex query. Fzf is used only to sort the
" results, and restarts rg each time the query changes to produce live results.
function! s:LiveRg(fullscreen, query) abort
  let cmd_args = 'rg --column --line-number --no-heading --color=always'
          \     .. ' --smart-case -- '
  let reload_cmd = cmd_args .. '{q}'
  let spec = #{options: ['--phony', '--prompt', 'LiveRg> ', '--query', a:query,
              \          '--bind', 'change:reload:' .. reload_cmd]}
  let init_cmd = cmd_args .. shellescape(a:query)
  call fzf#vim#grep(init_cmd, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -bang -nargs=* LiveRg call s:LiveRg(<bang>0, <q-args>)

" General mappings
nnoremap <leader>fb <Cmd>Buffers<CR>
nnoremap <leader>f/ <Cmd>BLines<CR>
nnoremap <leader>ff <Cmd>GFilesOrFiles<CR>
nnoremap <leader>fF <Cmd>Files<CR>
nnoremap <leader>fo <Cmd>History<CR>
nnoremap <leader>ft <Cmd>Tags<CR>

" Ripgrep
nnoremap <leader>fs <Cmd>Rg<CR>
nnoremap <leader>fg <Cmd>LiveRg<CR>
