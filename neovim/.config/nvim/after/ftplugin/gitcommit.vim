setlocal textwidth=80

let b:undo_ftplugin = get(b:, 'undo_ftplugin', '') .. "\nsetlocal textwidth<"
