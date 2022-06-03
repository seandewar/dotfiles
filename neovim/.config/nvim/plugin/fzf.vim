" General mappings
nnoremap <leader>fb <Cmd>Buffers<CR>
nnoremap <leader>ff <Cmd>Files<CR>
nnoremap <leader>fo <Cmd>History<CR>
nnoremap <leader>ft <Cmd>Tags<CR>
nnoremap <leader>f/ <Cmd>BLines<CR>

" Search file contents
if executable('rg')
    nnoremap <leader>fs <Cmd>Rg<CR>
elseif executable('ag')
    nnoremap <leader>fs <Cmd>Ag<CR>
endif

" Git
nnoremap <leader>fg <Cmd>GFiles<CR>
