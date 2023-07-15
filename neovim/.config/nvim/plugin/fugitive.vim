let g:conf_statusline_components.git = '%([%{FugitiveHead(7)}] %)'

augroup conf_fugitive_redraw_statusline
    autocmd!
    autocmd User FugitiveChanged
                \ call timer_start(0, {-> execute('redrawstatus!', '')})
augroup END

nnoremap <Leader>gl <Cmd>Git log -n 512 %<CR>
nnoremap <Leader>gL <Cmd>Git log -n 512<CR>
nnoremap <Leader>gs <Cmd>Git show<CR>
nnoremap <Leader>gd <Cmd>Gdiffsplit<CR>
nnoremap <Leader>gD <Cmd>G difftool<CR>
nnoremap <Leader>gm <Cmd>G mergetool<CR>
nnoremap <Leader>gb <Cmd>Git blame<CR>
nnoremap <Leader>gB :Git checkout<Space>
nnoremap <leader>gw <Cmd>Gwrite<CR>
nnoremap <leader>gR <Cmd>Gread<CR>
nnoremap <Leader>gM :GMove <C-R>=expand('%:p')<CR>
nnoremap <Leader>gr :G rebase -i<Space>
nnoremap <Leader>gc <Cmd>Git commit<CR>
nnoremap <Leader>gC <Cmd>Git commit --amend<CR>
