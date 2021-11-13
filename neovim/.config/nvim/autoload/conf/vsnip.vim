" My generic completefunc for vim-vsnip.
"
" Requires vim-vsnip-integ to be installed (it handles the expansion and
" additionalTextEdits).

function! s:SortItems(a, b) abort
    let a = tolower(empty(a:a.abbr) ? a:a.word : a:a.abbr)
    let b = tolower(empty(a:b.abbr) ? a:b.word : a:b.abbr)
    return a == b ? 0 : (a < b ? -1 : 1)
endfunction

function! conf#vsnip#completefunc(findstart, base) abort
    if a:findstart
        let before_cursor = getline('.')[:max([0, col('.') - 1])]
        return match(before_cursor, '\k\+$')
    elseif empty(a:base)
        return []
    endif

    let items = vsnip#get_complete_items(bufnr('%'))
    let matches = filter(items, {_, v -> v.word[:len(a:base) - 1] ==? a:base})
    for value in matches
        let value.kind = 's'
    endfor
    return sort(matches, funcref('s:SortItems'))
endfunction

function! conf#vsnip#complete() abort
    let startcol = conf#vsnip#completefunc(1, '')
    let base = startcol > 0 ? getline('.')[startcol:] : ''
    let matches = conf#vsnip#completefunc(0, base)
    if !empty(matches)
        call complete(startcol, matches)
    endif
endfunction
