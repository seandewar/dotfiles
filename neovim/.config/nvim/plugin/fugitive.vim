let g:conf_statusline_components.git = '%([%{FugitiveHead(7)}] %)'

augroup conf_fugitive_redraw_statusline
    autocmd!
    autocmd User FugitiveChanged
                \ call timer_start(0, {-> execute('redrawstatus!', '')})
augroup END

nnoremap <silent> <Leader>gg <Cmd>Git<CR>
nnoremap <silent> <Leader>gl <Cmd>Git log %<CR>
nnoremap <silent> <Leader>gL <Cmd>Git log<CR>
nnoremap <silent> <Leader>gs <Cmd>Git show<CR>
nnoremap <silent> <Leader>gd <Cmd>Gdiffsplit<CR>
nnoremap <silent> <Leader>gD <Cmd>G diff<CR>
nnoremap <silent> <Leader>gt <Cmd>G difftool<CR>
nnoremap <silent> <Leader>gm <Cmd>G mergetool<CR>
nnoremap <silent> <Leader>gb <Cmd>Git blame<CR>
nnoremap <Leader>gB :Git checkout<Space>
nnoremap <silent> <leader>gw <Cmd>Gwrite<CR>
nnoremap <silent> <leader>gR <Cmd>Gread<CR>
nnoremap <Leader>gM :GMove <C-R>=expand('%:p')<CR>
nnoremap <Leader>gr :G rebase -i<Space>
nnoremap <silent> <Leader>gc <Cmd>Git commit<CR>
nnoremap <silent> <Leader>gC <Cmd>Git commit --amend<CR>
nnoremap <Leader>gp <Cmd>Git pull<CR>
nnoremap <Leader>gP <Cmd>Git push<CR>
