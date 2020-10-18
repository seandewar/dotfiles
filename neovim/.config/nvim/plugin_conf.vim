""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sean Dewar's Plugin (Neo)Vim Configuration <https://github.com/seandewar>    "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Set $MYPLUGINCONF and $MYPLUGINLIST for easy access, resolving symlinks {{{1
let $MYPLUGINCONF = resolve(expand('<sfile>:p'))

" NOTE: plugin_list.vim is lazily-sourced when minpac functionality is needed;
" we shouldn't let plugin_list.vim set $MYPLUGINLIST itself, as it would need to
" be sourced in order to have $MYPLUGINLIST available, which isn't ideal...
"
" NOTE: using a temporary script variable rather than manipulating $MYPLUGINLIST
" directly avoids us from using :unlet on an environment variable from inside of
" the if statement; before vim 8.2.0602, the ':unlet $MYPLUGINLIST' command will
" run even when the enclosing if statement's condition evaluates to false. This
" approach preserves backward-compatibility, while also allowing the latest
" nvim (as of pre-release version 0.5.0-753-g4b00916e9) to not trigger the bug.
unlet $MYPLUGINLIST
let s:list_file = resolve(expand('<sfile>:p:h') . '/plugin_list.vim')

if filereadable(s:list_file)
    let $MYPLUGINLIST = s:list_file
endif

unlet s:list_file

" General Settings {{{1
" minpac {{{2
" on nvim, prefer installing minpac packages to the data directory over the
" config directory
if has('nvim')
    let g:minpac_base_dir = stdpath('data') . '/site'
endif

function! s:ReloadMinpac() abort
    packadd minpac

    " minpac (self-update)
    call minpac#init({'dir': get(g:, 'minpac_base_dir', '')})
    call minpac#add('k-takata/minpac', {'type': 'opt'})

    if !empty($MYPLUGINLIST)
        source $MYPLUGINLIST
    endif
endfunction

" color scheme {{{2
silent! colorscheme moonfly

" dirvish {{{2
" disable netrw (using dirvish instead)
let g:loaded_netrw = 1
let g:loaded_netrwPlugin = 1

let g:dirvish_mode = ':sort /^\v(.*[\/])|\ze/' " display directories first

" ultisnips {{{2
let g:UltiSnipsSnippetDirectories = [$MYVIMRUNTIME . '/ultisnips']

" ale {{{2
set completefunc=ale#completion#OmniFunc " lsp as user-defined ins-completion
let g:ale_fix_on_save = 1
let g:ale_linters_explicit = 1
let g:ale_fixers = {
            \ '*': ['remove_trailing_lines', 'trim_whitespace'],
            \ 'c': ['clang-format', 'remove_trailing_lines', 'trim_whitespace'],
            \ 'cpp': ['clang-format', 'remove_trailing_lines',
            \         'trim_whitespace'],
            \ 'markdown': ['remove_trailing_lines'],
            \ 'rust': ['rustfmt', 'remove_trailing_lines', 'trim_whitespace']
            \ }
let g:ale_linters = {
            \ 'c': ['clangd'],
            \ 'cpp': ['clangd'],
            \ 'rust': ['analyzer']
            \ }
let g:ale_c_clangformat_options = '-fallback-style=none'

let g:ale_sign_error = 'E'
let g:ale_sign_warning = 'W'
let g:ale_sign_info = 'I'
let g:ale_echo_msg_format = '[%linter%] %s'

function! ALELintStatusLine() abort
    if !exists('g:loaded_ale') || !get(g:, 'ale_enabled', 1)
                             \ || !get(b:, 'ale_enabled', 1)
        return ''
    endif

    if ale#engine#IsCheckingBuffer(bufnr())
        return '...'
    endif

    let counts = ale#statusline#Count(bufnr())
    if counts.total == 0
        return get(b:, 'ale_linted', 0) > 0 ? 'OK' : ''
    endif

    let total_err = counts.error + counts.style_error
    let total_warn = counts.warning + counts.style_warning

    let line  = total_err > 0 ? total_err . 'E' : ''
    let line .= total_warn > 0 ? ',' . total_warn . 'W' : ''
    let line .= counts.info > 0 ? ',' . counts.info . 'I' : ''
    return line
endfunction

let g:plugin_statusline = '%([%{ALELintStatusLine()}] %)'

augroup ale_update_statusline
    autocmd!
    autocmd User ALEJobStarted redrawstatus!
    autocmd User ALELintPost redrawstatus!
    autocmd User ALEFixPost redrawstatus!
augroup END

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
                ensure_installed = {
                    'bash', 'c', 'cpp', 'css', 'html', 'java', 'lua',
                    'markdown', 'python', 'regex', 'rust'
                },
                highlight = {enable = true},

                -- NOTE: uses the default keymaps
                -- (see ":help nvim-treesitter-incremental-selection-mod")
                incremental_selection = {enable = true},

                -- NOTE: the textobjects module does not define any keymaps for
                -- us, so we'll -- just use the recommended
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

" Commands {{{1
" minpac {{{2
command! -bar PackUpdate call <sid>ReloadMinpac() | call minpac#update('',
            \ {'do': 'source $MYPLUGINCONF | packloadall!'})
command! -bar PackClean call <sid>ReloadMinpac() | call minpac#clean()
command! -bar PackStatus call <sid>ReloadMinpac() | call minpac#status()

" Mappings {{{1
" ale {{{2
" NOTE: most of these binds only work for lsp servers
nnoremap <leader>al :ALELint<cr>
nnoremap <leader>af :ALEFix<cr>
nnoremap <leader>ah :ALEHover<cr>
nnoremap <leader>as :ALESymbolSearch<space>
nnoremap <leader>ar :ALEFindReferences<cr>
nnoremap <leader>aR :ALERename<cr>
nnoremap <leader>ad :ALEGoToDefinition<cr>
nnoremap <leader>at :ALEGoToTypeDefinition<cr>

" ultisnips {{{2
let g:UltiSnipsExpandTrigger = '<c-j>'
let g:UltiSnipsListSnippets = '<c-k>'
let g:UltiSnipsJumpForwardTrigger = '<c-j>'
let g:UltiSnipsJumpBackwardTrigger = '<c-k>'

" vim-fswitch {{{2
nnoremap <leader>oo :FSHere<cr>
nnoremap <leader>oh :FSLeft<cr>
nnoremap <leader>ol :FSRight<cr>
nnoremap <leader>ok :FSAbove<cr>
nnoremap <leader>oj :FSBelow<cr>
nnoremap <leader>oH :FSSplitLeft<cr>
nnoremap <leader>oL :FSSplitRight<cr>
nnoremap <leader>oK :FSSplitAbove<cr>
nnoremap <leader>oJ :FSSplitBelow<cr>

" vim-fugitive {{{2
nnoremap <leader>gg :Git<cr>
nnoremap <leader>gl :0Gclog \| cwindow<cr>
nnoremap <leader>gL :Gclog \| cwindow<cr>
nnoremap <leader>ge :Gedit<cr>
nnoremap <leader>gd :Gdiffsplit<cr>
nnoremap <leader>gb :Git blame<cr>
nnoremap <leader>gc :Git commit<cr>
nnoremap <leader>gw :Gwrite<cr>
nnoremap <leader>gr :Gread<cr>
nnoremap <leader>gps :Git push<cr>
nnoremap <leader>gpl :Git pull<cr>

" vim-qftoggle {{{2
nmap <leader>c <plug>(qftoggle_toggle_quickfix)
nmap <leader>l <plug>(qftoggle_toggle_loclist)
