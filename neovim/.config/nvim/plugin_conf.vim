""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sean Dewar's Plugin (Neo)Vim Configuration <https://github.com/seandewar>    "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" General Plugin Settings {{{1
" minpac {{{2
" on nvim, install minpac packages to the data directory over the config dir
if has('nvim')
    let g:minpac_base_dir = stdpath('data') . '/site'
endif

function! s:ReloadMinpac() abort
    packadd minpac

    " minpac (self-update)
    call minpac#init({'dir': get(g:, 'minpac_base_dir', '')})
    call minpac#add('k-takata/minpac', {'type': 'opt'})

    runtime plugin_list.vim
endfunction

" color scheme {{{2
silent! colorscheme moonfly

" neoformat {{{2
let g:neoformat_basic_format_trim = 1

" NOTE: can be overridden on a per-buffer basis with b:format_on_save
let g:format_on_save = 1

augroup neoformat_on_save
    autocmd!
    autocmd BufWritePre *
                \ if get(b:, 'format_on_save', get(g:, 'format_on_save', 0))
                \ | silent Neoformat
                \ | endif
augroup END

" ultisnips {{{2
let g:UltiSnipsSnippetDirectories = [$MYVIMRUNTIME . '/ultisnips']

" nvim-treesitter {{{2
if has('nvim-0.5')
    packadd nvim-treesitter
    packadd nvim-treesitter-textobjects

    " FIXME nvim-treesitter misbehaves with inccommand set; disable it for now
    set inccommand=

    " NOTE: if we don't wrap ':lua << EOF' in a function, the Lua code will
    " still be ran even when the if condition above evaluates to false!
    " (see ':help script-here' for more information)
    function! s:SetupNvimTreesitter() abort
        lua << EOF
          require('nvim-treesitter.configs').setup({
            -- NOTE: these bundled modules define default keymaps, if any
            -- (see ":help nvim-treesitter-incremental-selection-mod")
            highlight = {enable = true},
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
" vim-lsp {{{2
let g:plugin_statusline_functions = [{is_current -> exists('g:lsp_loaded')
            \ ? plugin_conf#lsp#statusline(is_current) : ''}]

" Commands {{{1
" minpac {{{2
command! -bar PackUpdate call <sid>ReloadMinpac() | call minpac#update('',
            \ {'do': 'runtime plugin_list.vim | packloadall!'})
command! -bar PackClean call <sid>ReloadMinpac() | call minpac#clean()
command! -bar PackStatus call <sid>ReloadMinpac() | call minpac#status()

" vim-lsp {{{2
if !exists('g:lsp_loaded')
    command! -bar LspEnable call plugin_conf#lsp#enable() | delcommand LspEnable
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
nnoremap <silent> <leader>gd :Gdiffsplit<cr>
nnoremap <silent> <leader>gb :Git blame<cr>
nnoremap <silent> <leader>gc :Git commit<cr>
nnoremap <silent> <leader>gC :Git commit --amend<cr>
nnoremap <silent> <leader>gw :Gwrite<cr>
nnoremap <silent> <leader>gr :Gread<cr>
nnoremap <silent> <leader>gps :Git push<cr>
nnoremap <silent> <leader>gpl :Git pull<cr>

" vim-qftoggle {{{2
nnoremap <silent> <leader>c :botright Ctoggle<cr>
nmap <leader>C <plug>(qftoggle_toggle_loclist)

nmap ]c <plug>(qftoggle_quickfix_next)
nmap [c <plug>(qftoggle_quickfix_previous)

nmap ]C <plug>(qftoggle_loclist_next)
nmap [C <plug>(qftoggle_loclist_previous)
