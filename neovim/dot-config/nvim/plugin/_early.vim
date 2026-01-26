" First plugin/ file to be sourced after init.vim.
" A .vim file because all Vim script plugin/ files are sourced before Lua.
" Used for things that need to be set early, or miscellaneous stuff.

set rulerformat=%!v:lua.require'conf.statusline'.rulerformat()
set statusline=%!v:lua.require'conf.statusline'.statusline()
set tabline=%!v:lua.require'conf.statusline'.tabline()

colorscheme zensmitten

" These options only apply to the non-bundled Zig ftplugin.
let g:zig_fmt_autosave = 0
let g:zig_fmt_parse_errors = 0
