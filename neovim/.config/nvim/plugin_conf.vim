""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sean Dewar's Plugin (Neo)Vim Configuration <https://github.com/seandewar>    "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" General Plugin Settings {{{1
" color scheme {{{2
augroup conf_colorscheme_customization
    autocmd!
    autocmd ColorScheme moonfly
                \ highlight StatusLineError
                    \ ctermfg=1 ctermbg=236 guifg=#ff5454 guibg=#303030
                \ | highlight StatusLineWarn
                    \ ctermfg=3 ctermbg=236 guifg=#e3c78a guibg=#303030
                \ | highlight StatusLineInfo
                    \ ctermfg=12 ctermbg=236 guifg=#74b2ff guibg=#303030
augroup END

let g:moonflyNormalFloat = 1
silent! colorscheme moonfly

" localvimrc
let g:localvimrc_ask = 0

" neoformat {{{2
let g:neoformat_basic_format_trim = 1

" Status Line Settings {{{1
" vim-fugitive {{{2
let g:plugin_statusline_functions =
            \ [{is_current -> exists('g:loaded_fugitive') && is_current
            \                 ? '%([%{FugitiveHead(7)}] %)' : ''}]

" Neovim Diagnostics and LSP {{{2
if has('nvim-0.5.1')
    let g:plugin_statusline_functions += [{is_current ->
                \ '%{%luaeval(''require("conf.diagnostic").statusline(_A)'','
                \ .. (is_current ? 'v:true' : 'v:false') .. ')%}'}]

    let g:plugin_statusline_functions += [{is_current ->
                \ '%{%luaeval(''require("conf.lsp").statusline(_A)'','
                \ .. (is_current ? 'v:true' : 'v:false') .. ')%}'}]
end

" Commands {{{1
" minpac {{{2
" NOTE: use :execute so that expand('<sfile>') results in this script's path
execute 'command! -bar PackUpdate call plugin_conf#minpac#reload() '
            \ . '| call minpac#update('''', '
            \ . '{''do'': ''source ' . expand('<sfile>') . ' | packloadall!''})'
command! -bar PackClean call plugin_conf#minpac#reload() | call minpac#clean()
command! -bar PackStatus call plugin_conf#minpac#ensure_init()
            \ | call minpac#status()

" Mappings {{{1
" neoformat {{{2
nnoremap <silent> <f4> :Neoformat<cr>
vnoremap <silent> <f4> :Neoformat<cr>

" vim-vsnip {{{2
imap <expr> <c-j> vsnip#available(1) ? '<plug>(vsnip-expand-or-jump)' : '<c-j>'
smap <expr> <c-j> vsnip#available(1) ? '<plug>(vsnip-expand-or-jump)' : '<c-j>'
imap <expr> <c-k> vsnip#jumpable(-1) ? '<plug>(vsnip-jump-prev)' : '<c-k>'
smap <expr> <c-k> vsnip#jumpable(-1) ? '<plug>(vsnip-jump-prev)' : '<c-k>'

" cut text to use as $TM_SELECTED_TEXT in the next snippet; the normal mode map
" accepts a subsequent motion
xmap <c-j> <plug>(vsnip-cut-text)
nmap <c-j> <plug>(vsnip-cut-text)

" vim-fugitive {{{2
nnoremap <silent> <leader>gg :Git<cr>
nnoremap <silent> <leader>gl :Git log %<cr>
nnoremap <silent> <leader>gL :Git log<cr>
nnoremap <silent> <leader>gs :Git show<cr>
nnoremap <silent> <leader>gd :Gdiffsplit<cr>
nnoremap <silent> <leader>gD :G diff<cr>
nnoremap <silent> <leader>gt :G difftool<cr>
nnoremap <silent> <leader>gm :G mergetool<cr>
nnoremap <silent> <leader>gb :Git blame<cr>
nnoremap <leader>gB :Git checkout<space>
nnoremap <silent> <leader>gw :Gwrite<cr>
nnoremap <silent> <leader>gR :Gread<cr>
nnoremap <leader>gM :GRename <c-r>=expand('%:t')<cr>
nnoremap <leader>gr :G rebase -i<space>
nnoremap <silent> <leader>gc :Git commit<cr>
nnoremap <silent> <leader>gC :Git commit --amend<cr>
nnoremap <leader>gp :Git pull<cr>
nnoremap <leader>gP :Git push<cr>

" vim-qftoggle {{{2
nmap <leader>c <plug>(qftoggle_toggle_quickfix)
nmap <leader>l <plug>(qftoggle_toggle_loclist)

nmap ]c <plug>(qftoggle_quickfix_next)
nmap [c <plug>(qftoggle_quickfix_previous)

nmap ]l <plug>(qftoggle_loclist_next)
nmap [l <plug>(qftoggle_loclist_previous)

" Neovim 0.5+ Lua Plugin Settings {{{1
if has('nvim-0.5')
    lua require("conf.util").reload()
endif
