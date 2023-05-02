" Test out the new TOP SECRET Neovim default colorscheme.
if has('nvim')
    colorscheme neovim
    finish
endif

" Solves the background priority issues Nvim has when linking to Normal.
" See issue neovim#9019.
let g:paragon_transparent_bg = 1

colorscheme paragon
