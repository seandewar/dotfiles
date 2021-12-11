setlocal textwidth=80
let b:EditorConfig_disable = 1

call conf#ft#undo_ftplugin(
            \ 'setlocal textwidth<', 'unlet! b:EditorConfig_disable')
