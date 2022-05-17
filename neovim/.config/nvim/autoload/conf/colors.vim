function! s:HlAttrMap(name) abort
    " Follow links until we find the highlight
    let name = a:name
    while 1
        if !hlexists(name) | return {} | endif
        let lines = split(trim(execute('highlight ' .. name)), "\n")
        let parts = split(lines[-1])[(len(lines) == 1 ? 2 : 0):]
        if parts[0] ==# 'cleared' | return {} | endif
        if parts[0] !=# 'links' | break | endif
        let name = parts[2]
    endwhile
    let attrs = map(parts, {_, v -> split(v, '=')})
    let attr_map = {}
    for [k, v] in attrs
        let attr_map[k] = v
    endfor
    return attr_map
endfunction

" Returns a string of :highlight attributes when combining the attributes of
" highlights 'base' and 'override'. Attributes from 'override' in 'attr_list'
" overwrite those in 'base', allowing you to combine highlights.
"
" If 'base' or 'override' are not defined, they are treated as cleared.
"
" The resulting highlight can be defined like:
" :execute 'highlight C ' .. conf#colors#hl_override('A', 'B', ['ctermfg'])
function! conf#colors#hl_override(base, override, attr_list) abort
    let override_map = s:HlAttrMap(a:override)
    let map = s:HlAttrMap(a:base)
    for a in a:attr_list
        if exists('override_map[''' .. a .. ''']')
            let map[a] = override_map[a]
        endif
    endfor
    return join(map(items(map), {_, kv -> kv[0] .. '=' .. kv[1]}), ' ')
endfunction
