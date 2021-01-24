""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sean Dewar's Plugin (Neo)Vim Configuration <https://github.com/seandewar>    "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" General Plugin Settings {{{1
" color scheme {{{2
silent! colorscheme moonfly

" neoformat {{{2
let g:neoformat_basic_format_trim = 1

" NOTE: formatting on save can be globally enabled with g:format_on_save, or
" overridden on a per-buffer basis with b:format_on_save
augroup neoformat_on_save
    autocmd!
    autocmd BufWritePre *
                \ if get(b:, 'format_on_save', get(g:, 'format_on_save', 0))
                \ | silent Neoformat
                \ | endif
augroup END

" ultisnips {{{2
" If we can't use py3, don't load ultisnips, as it'll constantly throw errors
try
    python3 #
    packadd ultisnips
    let g:UltiSnipsSnippetDirectories = [$MYVIMRUNTIME . '/ultisnips']
endtry

" nvim-treesitter {{{2
if has('nvim-0.5')
    packadd nvim-treesitter
    packadd nvim-treesitter-textobjects

    " NOTE: if we don't wrap ':lua << EOF' in a function, the Lua code will
    " still be ran even when the if condition above evaluates to false!
    " (see ':help script-here' for more information)
    function! s:SetupNvimTreesitter() abort
        lua << EOF
          require('nvim-treesitter.configs').setup({
            -- NOTE: these bundled modules define default keymaps, if any
            -- (see ":help nvim-treesitter-incremental-selection-mod")

            -- FIXME: highlights misbehave when buffer changes sometimes
            --        (e.g: 'inccommand'), requiring :e to fix; disable for now
            -- highlight = {enable = true},

            -- FIXME: indents misbehave right now as the module is currently
            --        undergoing a refactor; disable for now
            -- indent = {enable = true},

            incremental_selection = {enable = true},

            -- NOTE: these additional modules do not define any keymaps for us
            -- so we'll just use the recommended ones from the docs
            -- (see ":help nvim-treesitter-textobjects-mod")
            textobjects = {
              select = {
                enable = true,
                keymaps = {
                  ['af'] = '@function.outer',
                  ['if'] = '@function.inner',
                  ['ac'] = '@class.outer',
                  ['ic'] = '@class.inner'
                }
              },
              move = {
                enable = true,
                goto_next_start = {
                  [']m'] = '@function.outer',
                  [']]'] = '@class.outer'
                },
                goto_next_end = {
                  [']M'] = '@function.outer',
                  [']['] = '@class.outer'
                },
                goto_previous_start = {
                  ['[m'] = '@function.outer',
                  ['[['] = '@class.outer'
                },
                goto_previous_end = {
                  ['[M'] = '@function.outer',
                  ['[]'] = '@class.outer'
                }
              }
            }
          })
EOF
    endfunction

    call s:SetupNvimTreesitter()
endif

" Status Line Settings {{{1
" vim-fugitive {{{2
let g:plugin_statusline_functions  =
            \ [{is_current -> exists('g:loaded_fugitive') && is_current
                            \ ? '%([%{FugitiveHead(7)}] %)' : ''}]

" vim-lsp {{{2
let g:plugin_statusline_functions += [{is_current -> exists('g:lsp_loaded')
            \ ? plugin_conf#vim_lsp#statusline(is_current) : ''}]

" Commands {{{1
" minpac {{{2
" NOTE: use :execute so that expand('<sfile>') results in this script's path
execute 'command! -bar PackUpdate call plugin_conf#minpac#reload() '
            \ . '| call minpac#update('''', '
            \ . '{''do'': ''source ' . expand('<sfile>') . ' | packloadall!''})'
command! -bar PackClean call plugin_conf#minpac#reload() | call minpac#clean()
command! -bar PackStatus call plugin_conf#minpac#reload() | call minpac#status()

" vim-lsp {{{2
if !exists('g:lsp_loaded')
    command! -bar LspEnable call plugin_conf#vim_lsp#enable()
                \ | delcommand LspEnable
endif

" Mappings {{{1
" neoformat {{{2
nnoremap <silent> <f4> :Neoformat<cr>
vnoremap <silent> <f4> :Neoformat<cr>

" ultisnips {{{2
let g:UltiSnipsExpandTrigger = '<c-j>'
let g:UltiSnipsListSnippets = '<c-k>'
let g:UltiSnipsJumpForwardTrigger = '<c-j>'
let g:UltiSnipsJumpBackwardTrigger = '<c-k>'

" vim-fugitive {{{2
nnoremap <silent> <leader>gg :Git<cr>
nnoremap <silent> <leader>gl :Git log<cr>
nnoremap <silent> <leader>gL :Git log %<cr>
nnoremap <silent> <leader>gd :G difftool<cr>
nnoremap <silent> <leader>gD :Gdiffsplit<cr>
nnoremap <silent> <leader>gm :G mergetool<cr>
nnoremap <leader>gr :G rebase -i<space>
nnoremap <silent> <leader>gb :Git blame<cr>
nnoremap <silent> <leader>gc :Git commit<cr>
nnoremap <silent> <leader>gC :Git commit --amend<cr>
nnoremap <silent> <leader>gw :Gwrite<cr>
nnoremap <silent> <leader>gR :Gread<cr>
nnoremap <silent> <leader>gps :Git push<cr>
nnoremap <silent> <leader>gpl :Git pull<cr>

" vim-qftoggle {{{2
nmap <leader>c <plug>(qftoggle_toggle_quickfix)
nmap <leader>l <plug>(qftoggle_toggle_loclist)

nmap ]c <plug>(qftoggle_quickfix_next)
nmap [c <plug>(qftoggle_quickfix_previous)

nmap ]l <plug>(qftoggle_loclist_next)
nmap [l <plug>(qftoggle_loclist_previous)
