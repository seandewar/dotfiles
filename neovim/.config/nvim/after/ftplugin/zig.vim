setlocal textwidth=0  " disable as zig-fmt doesn't care about wrapping
call conf#ft#undo_ftplugin('setlocal textwidth<')
