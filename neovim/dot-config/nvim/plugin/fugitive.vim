lua require("conf.statusline").components.git = "%(%{FugitiveStatusline()} %)"

augroup conf_fugitive_redraw_statusline
    autocmd!
    autocmd User FugitiveChanged
                \ call timer_start(0, {-> execute('redrawstatus!', '')})
augroup END

nnoremap <Leader>gl :Git log -n 128 -- %<Left><Left><Left><Left><Left>
nnoremap <Leader>gL :Git log -n 128
nnoremap <Leader>gs <Cmd>Git show<CR>
nnoremap <Leader>gd <Cmd>Gdiffsplit<CR>
nnoremap <Leader>gD :Git diff<Space>
nnoremap <Leader>gm <Cmd>Git mergetool<CR>
nnoremap <Leader>gb <Cmd>Git blame<CR>
nnoremap <Leader>gr :Git rebase -i<Space>
nnoremap <Leader>gc <Cmd>Git commit<CR>
nnoremap <Leader>gC <Cmd>Git commit --amend<CR>
