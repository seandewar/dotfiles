setlocal textwidth=0  " disable as zig-fmt doesn't care about wrapping

let b:undo_ftplugin = get(b:, 'undo_ftplugin', '') .. "\nsetlocal textwidth<"
