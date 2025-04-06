setlocal textwidth=0  " disable as zig-fmt doesn't care about wrapping

" Prepend, as the zig ftplugin may use "au!" at the end, causing our commands to
" be treated as part of :autocmd (regardless of our use of newlines).
let b:undo_ftplugin = "setlocal textwidth<\n" .. get(b:, 'undo_ftplugin', '')
