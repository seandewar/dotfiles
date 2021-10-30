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

function! s:ExpandCompletion() abort
    " vsnip user data is a JSON-encoded dict with the key "vsnip", which
    " contains a list of snippet lines
    if type(v:completed_item) != v:t_dict
        return
    endif
    let user_data = v:completed_item.user_data
    if type(user_data) != v:t_string
        return
    endif
    try
        let user_data = json_decode(user_data)
    catch
        return
    endtry
    if type(user_data) != v:t_dict
        return
    endif
    let user_data = get(user_data, 'vsnip', {})
    if empty(user_data)
        return
    endif

    let snippet = join(user_data.snippet, "\n")
    if !empty(snippet)
        " Undo the word inserted via completion
        let word_len = len(v:completed_item.word)
        if word_len > 1
            execute 'normal! ' .. (word_len - 1) .. 'X'
        endif
        normal! x
        call cursor(line('.'), col('.') + 1)
        call vsnip#anonymous(snippet)
    endif
endfunction

augroup conf_vsnip_complete
    autocmd!
    autocmd CompleteDone * call s:ExpandCompletion()
augroup END
