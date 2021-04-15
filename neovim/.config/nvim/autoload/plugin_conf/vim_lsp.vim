""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sean Dewar's Autoload Config for vim-lsp <https://github.com/seandewar>      "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" General Plugin Settings {{{1
" vim-lsp {{{2
let g:lsp_diagnostics_signs_error = {'text': 'X'}
let g:lsp_diagnostics_signs_warning = {'text': '!'}
let g:lsp_diagnostics_signs_information = {'text': 'i'}
let g:lsp_diagnostics_signs_hint = {'text': '>'}
let g:lsp_document_code_action_signs_hint  = {'text': '*'}

let g:lsp_diagnostics_signs_priority_map = {
            \ 'LspError': 12,
            \ 'LspWarning': 11,
            \ }

let g:lsp_work_done_progress_enabled = 1
let g:lsp_diagnostics_highlights_enabled = 0
let g:lsp_diagnostics_virtual_text_enabled = 0
let g:lsp_diagnostics_float_cursor = 1

function! plugin_conf#vim_lsp#enable() abort
    packadd vim-lsp
    packadd vim-lsp-settings
    packadd vim-vsnip-integ

    call lsp#enable()
    call vsnip_integ#integration#attach()
    echomsg "LSP enabled for new buffers! "
                \ . "Reload old buffers with :edit to enable LSP for them."
endfunction

function! s:SetupBuffer() abort
    " vim-lsp handles completion menu preview and floating/popup windows itself
    setlocal completeopt-=preview completeopt-=popup
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes

    call s:SetupBufferMappings()
endfunction

augroup lsp_setup_buffer
    autocmd!
    autocmd User lsp_buffer_enabled call s:SetupBuffer()

    " NOTE: as of 0.5, neovim excessively redraws its statusline, which causes
    " our refresh-limiting logic to be ignored; still works in vim, though
    " (see neovim/neovim#4847)
    autocmd User lsp_progress_updated call s:StatusLineProgressRedraw()
augroup END

" vim-lsp-settings {{{2
let g:lsp_settings_enable_suggestions = 0

" Status Line Settings {{{1
function! plugin_conf#vim_lsp#statusline(is_current) abort
    if !a:is_current || !exists('g:lsp_loaded')
        return ''
    endif

    let counts = lsp#get_buffer_diagnostics_counts()
    let items = []

    if counts['error'] > 0
        let items += ['%#LspErrorText#'
                    \ . get(get(g:, 'lsp_diagnostics_signs_error', {}),
                    \       'text', 'E')
                    \ . counts['error']]
    endif
    if counts['warning'] > 0
        let items += ['%#LspWarningText#'
                    \ . get(get(g:, 'lsp_diagnostics_signs_warning', {}),
                    \       'text', 'W')
                    \ . counts['warning']]
    endif
    if counts['information'] > 0
        let items += [get(get(g:, 'lsp_diagnostics_signs_information', {}),
                    \     'text', 'I')
                    \ . counts['information']]
    endif
    if counts['hint'] > 0
        let items += [get(get(g:, 'lsp_diagnostics_signs_hint', {}),
                    \     'text', 'H')
                    \ . counts['hint']]
    endif

    let counts_str = !empty(items) ? '[' . join(items, '%* ') . '%*] ' : ''
    let progress = lsp#get_progress()
    let status_str = ''

    if !empty(progress)
        let status_str .= progress[0].server . ': '
        let status_str .= progress[0].title . ' '
        let status_str .= progress[0].message . ' '

        let percentage = get(progress[0], 'percentage', '')
        if !empty(percentage)
            let status_str .= '(' . percentage . '%%) '
        endif
    endif

    return counts_str . status_str
endfunction

let s:ignore_progress_redraws_until = 0
function! s:StatusLineProgressRedraw() abort
    let now = reltimefloat(reltime())
    if now < s:ignore_progress_redraws_until && !empty(lsp#get_progress())
        return
    endif

    let s:ignore_progress_redraws_until = now + 0.5
    redrawstatus
endfunction

" Mappings {{{1
function! s:SetupBufferMappings() abort
    " popup scrolling (mostly for compatibility with vim, as it doesn't have
    " focusable popups like nvim does)
    inoremap <buffer> <expr> <c-f> lsp#scroll(+4)
    inoremap <buffer> <expr> <c-d> lsp#scroll(-4)

    " override tag jumping behaviour for jumping to definitions
    if exists('+tagfunc')
        setlocal tagfunc=lsp#tagfunc
    else
        nmap <buffer> <c-]> <plug>(lsp-definition)
    endif

    if &filetype !~# '\<vim\>'
        nmap <buffer> K <plug>(lsp-hover)
    endif
    " TODO: find better mapping for signature help (c-k conflicts with snippets)
    nmap <buffer> <m-k> <plug>(lsp-signature-help)
    imap <buffer> <m-k> <c-\><c-o><plug>(lsp-signature-help)

    nmap <buffer> gd <plug>(lsp-declaration)
    nmap <buffer> gD <plug>(lsp-implementation)
    nmap <buffer> 1gD <plug>(lsp-type-definition)

    nmap <buffer> <space>w <plug>(lsp-workspace-symbol-search)
    nmap <buffer> <space>d <plug>(lsp-document-symbol-search)
    nmap <buffer> <space>r <plug>(lsp-references)
    nmap <buffer> <space>a <plug>(lsp-code-action)
    nmap <buffer> <space>l <plug>(lsp-code-lens)
    nmap <buffer> <space>R <plug>(lsp-rename)
    xmap <buffer> <space>f <plug>(lsp-document-range-format)
    nmap <buffer> <space>F <plug>(lsp-document-format)

    nmap <buffer> <space><space> <plug>(lsp-document-diagnostics)
    nmap <buffer> ]<space> <plug>(lsp-next-diagnostic)
    nmap <buffer> [<space> <plug>(lsp-previous-diagnostic)

    nmap <buffer> <space>s <plug>(lsp-switch-source-header)
endfunction
