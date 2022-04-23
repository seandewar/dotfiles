""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sean Dewar's Plugin (Neo)Vim Configuration <https://github.com/seandewar>    "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" General Plugin Settings {{{1
" color scheme {{{2
colorscheme paragon

" localvimrc {{{2
let g:localvimrc_name = ['.lvimrc', '.vim/lvimrc']

" Sandbox is easy to escape and causes another prompt; just check manually.
let g:localvimrc_sandbox = 0

" copilot.vim {{{2
let g:copilot_enabled = 0

" neoformat {{{2
let g:neoformat_basic_format_trim = 1

" vim-vsnip {{{2
set completefunc=conf#vsnip#completefunc

" Status Line Settings {{{1
" vim-fugitive {{{2
let g:conf_statusline_components.git = '%([%{FugitiveHead(7)}] %)'

augroup conf_fugitive_redraw_statusline
    autocmd!
    autocmd User FugitiveChanged
                \ call timer_start(0, {-> execute('redrawstatus!', '')})
augroup END

" Commands {{{1
" minpac {{{2
" NOTE: use :execute so that expand('<sfile>') results in this script's path
execute 'command! -bar PackUpdate '
            \ .. 'call conf#minpac#reload() | call minpac#update("", '
            \ .. '#{do: "source ' .. expand('<sfile>') .. ' | packloadall!"})'
command! -bar PackClean call conf#minpac#reload() | call minpac#clean()
command! -bar PackStatus call conf#minpac#ensure_init() | call minpac#status()

" Mappings {{{1
" neoformat {{{2
nnoremap <silent> <F4> <Cmd>Neoformat<CR>
vnoremap <silent> <F4> <Cmd>Neoformat<CR>

" vim-vsnip {{{2
imap <expr> <Tab> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<Tab>'
smap <expr> <Tab> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<Tab>'
imap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'
smap <expr> <S-Tab> vsnip#jumpable(-1) ? '<Plug>(vsnip-jump-prev)' : '<S-Tab>'
xmap <Tab> <Plug>(vsnip-cut-text)

" copilot.vim {{{2
let g:copilot_no_tab_map = v:true
imap <silent> <script> <expr> <C-J> copilot#Accept("\<C-J>")

" vim-fugitive {{{2
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
nnoremap <Leader>gM <Cmd>GRename <C-R>=expand('%:t')<CR>
nnoremap <Leader>gr :G rebase -i<Space>
nnoremap <silent> <Leader>gc <Cmd>Git commit<CR>
nnoremap <silent> <Leader>gC <Cmd>Git commit --amend<CR>
nnoremap <Leader>gp <Cmd>Git pull<CR>
nnoremap <Leader>gP <Cmd>Git push<CR>

" vim-qftoggle {{{2
nmap <Leader>c <Plug>(qftoggle_toggle_quickfix)
nmap <Leader>l <Plug>(qftoggle_toggle_loclist)

nmap ]c <Plug>(qftoggle_quickfix_next)
nmap [c <Plug>(qftoggle_quickfix_previous)

nmap ]l <Plug>(qftoggle_loclist_next)
nmap [l <Plug>(qftoggle_loclist_previous)

" Neovim Plugins {{{1
if has('nvim')
    lua require("conf.util").reload()
endif
