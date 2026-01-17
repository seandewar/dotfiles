" This is the first plugin/ file to be sourced after my init.vim.
" It's a .vim file as Nvim sources all Vim script plugin/ files before Lua.
" Important for setting up vim.pack, but also contains miscellaneous settings.

set rulerformat=%!v:lua.require'conf.statusline'.rulerformat()
set statusline=%!v:lua.require'conf.statusline'.statusline()
set tabline=%!v:lua.require'conf.statusline'.tabline()

colorscheme bruvbox

" These options only apply to the non-bundled Zig ftplugin.
let g:zig_fmt_autosave = 0
let g:zig_fmt_parse_errors = 0

execute 'source' $'{stdpath('config')}/pack.lua'
