" Name:       paragon.vim
" Version:    0.1.0
" Maintainer: Sean Dewar <https://github.com/seandewar>
" License:    The MIT License (MIT)
"
" A minimal colour scheme for Vim and Neovim based on paramount.vim:
" https://github.com/owickstrom/vim-colors-paramount

hi clear
let g:colors_name = 'paragon'

let s:black         = {'gui': '#000000', 'cterm': '232'}
let s:medium_gray   = {'gui': '#767676', 'cterm': '243'}
let s:white         = {'gui': '#f1f1f1', 'cterm': '15' }
let s:actual_white  = {'gui': '#ffffff', 'cterm': '231'}
let s:subtle_black  = {'gui': '#303030', 'cterm': '236'}
let s:light_black   = {'gui': '#262626', 'cterm': '235'}
let s:lighter_black = {'gui': '#4e4e4e', 'cterm': '239'}
let s:light_gray    = {'gui': '#a8a8a8', 'cterm': '248'}
let s:lighter_gray  = {'gui': '#c6c6c6', 'cterm': '251'}
let s:lightest_gray = {'gui': '#eeeeee', 'cterm': '255'}
let s:pink          = {'gui': '#fb007a', 'cterm': '9'  }
let s:dark_red      = {'gui': '#c10714', 'cterm': '1'  }
let s:light_red     = {'gui': '#e22633', 'cterm': '1'  }
let s:orange        = {'gui': '#d75f5f', 'cterm': '167'}
let s:darker_blue   = {'gui': '#005f87', 'cterm': '18' }
let s:dark_blue     = {'gui': '#008ec4', 'cterm': '32' }
let s:blue          = {'gui': '#20bbfc', 'cterm': '12' }
let s:light_blue    = {'gui': '#b6d6fd', 'cterm': '153'}
let s:dark_cyan     = {'gui': '#20a5ba', 'cterm': '6'  }
let s:light_cyan    = {'gui': '#4fb8cc', 'cterm': '14' }
let s:dark_green    = {'gui': '#10a778', 'cterm': '2'  }
let s:light_green   = {'gui': '#5fd7a7', 'cterm': '10' }
let s:dark_purple   = {'gui': '#af5fd7', 'cterm': '134'}
let s:light_purple  = {'gui': '#a790d5', 'cterm': '140'}
let s:yellow        = {'gui': '#f3e430', 'cterm': '11' }
let s:light_yellow  = {'gui': '#ffff87', 'cterm': '228'}
let s:dark_yellow   = {'gui': '#a89c14', 'cterm': '3'  }

let s:background = &background
if &background == 'dark'
    let s:purple         = s:light_purple
    let s:cyan           = s:light_cyan
    let s:green          = s:light_green
    let s:red            = s:light_red
    let s:yellow         = s:light_yellow

    let s:bg             = s:black
    let s:bg_subtle      = s:lighter_black
    let s:bg_very_subtle = s:subtle_black
    let s:bg_most_subtle = s:light_black
    let s:norm           = s:lighter_gray
    let s:norm_subtle    = s:medium_gray
else
    let s:purple         = s:dark_purple
    let s:cyan           = s:dark_cyan
    let s:green          = s:dark_green
    let s:red            = s:dark_red
    let s:yellow         = s:dark_yellow

    let s:bg             = s:actual_white
    let s:bg_subtle      = s:light_gray
    let s:bg_very_subtle = s:lightest_gray
    let s:bg_most_subtle = s:white
    let s:norm           = s:light_black
    let s:norm_subtle    = s:medium_gray
endif

let s:accent = s:orange
let s:accent_contrast = s:black

" https://github.com/noahfrederick/vim-hemisu/
function! s:h(group, style) abort
    execute 'highlight' a:group
            \ 'guifg='   has_key(a:style, 'fg')    ? a:style.fg.gui   : 'NONE'
            \ 'guibg='   has_key(a:style, 'bg')    ? a:style.bg.gui   : 'NONE'
            \ 'guisp='   has_key(a:style, 'sp')    ? a:style.sp.gui   : 'NONE'
            \ 'gui='     has_key(a:style, 'gui')   ? a:style.gui      : 'NONE'
            \ 'ctermfg=' has_key(a:style, 'fg')    ? a:style.fg.cterm : 'NONE'
            \ 'ctermbg=' has_key(a:style, 'bg')    ? a:style.bg.cterm : 'NONE'
            \ 'cterm='   has_key(a:style, 'cterm') ? a:style.cterm    : 'NONE'
endfunction

call s:h('Normal', {'fg': s:norm})

" restore &background's value in case changing Normal changed &background
" (:help :hi-normal-cterm)
if &background != s:background
    execute 'set background=' . s:background
endif

call s:h('Cursor',   {'bg': s:accent, 'fg': s:norm})
call s:h('Comment',  {'fg': s:bg_subtle, 'gui': 'italic', 'cterm': 'italic'})

call s:h('Constant', {'fg': s:accent})
hi! link Character Constant
hi! link Number    Constant
hi! link Boolean   Constant
hi! link Float     Constant
hi! link String    Constant

hi! link Identifier Normal
hi! link Function   Identifier

call s:h('Statement', {'fg': s:norm_subtle})
hi! link Conditonal Statement
hi! link Repeat     Statement
hi! link Label      Statement
hi! link Keyword    Statement
hi! link Exception  Statement

call s:h('PreProc',   {'fg': s:norm_subtle})
hi! link Include   PreProc
hi! link Define    PreProc
hi! link Macro     PreProc
hi! link PreCondit PreProc

hi! link Type         Normal
hi! link StorageClass Type
hi! link Structure    Type
hi! link Typedef      Type

call s:h('Operator',   {'fg': s:norm, 'cterm': 'bold', 'gui': 'bold'})
call s:h('Tag',        {'fg': s:norm_subtle})
call s:h('Debug',      {'fg': s:norm_subtle})

call s:h('Special',    {'fg': s:norm_subtle})
call s:h('SpecialKey', {'fg': s:blue, 'gui': 'italic', 'cterm': 'italic'})
hi! link SpecialComment Special
hi! link SpecialChar    Special
hi! link Delimiter      Special

call s:h('Underlined', {'fg': s:norm, 'gui': 'underline', 'cterm': 'underline'})
call s:h('Todo',       {'fg': s:norm_subtle, 'gui': 'bold', 'cterm': 'bold'})
call s:h('Error',      {'fg': s:actual_white, 'bg': s:red, 'cterm': 'bold'})

call s:h('Ignore',     {})
call s:h('NonText',    {'fg': s:bg_subtle})
hi! link Conceal NonText

call s:h('Directory',  {'fg': s:accent})
call s:h('ErrorMsg',   {'fg': s:red})
call s:h('IncSearch',  {'bg': s:blue, 'fg': s:black})
call s:h('Search',     {'bg': s:accent, 'fg': s:accent_contrast})
hi! link CurSearch IncSearch

call s:h('MoreMsg',    {'fg': s:medium_gray, 'cterm': 'bold', 'gui': 'bold'})
hi! link ModeMsg MoreMsg

call s:h('LineNr',       {'fg': s:bg_subtle})
call s:h('CursorLineNr', {'fg': s:accent, 'bg': s:bg_very_subtle})
call s:h('Question',     {'fg': s:blue})
call s:h('StatusLine',   {'bg': s:bg_most_subtle})
call s:h('StatusLineNC', {'bg': s:bg_most_subtle, 'fg': s:norm_subtle})
call s:h('VertSplit',    {'fg': s:bg_most_subtle})
call s:h('Title',        {'fg': s:blue})
call s:h('Visual',       {'fg': s:black, 'bg': s:blue})
call s:h('VisualNOS',    {'fg': s:norm, 'bg': s:bg_subtle})
call s:h('WarningMsg',   {'fg': s:yellow})
call s:h('WildMenu',     {'fg': s:bg, 'bg': s:norm})
call s:h('Folded',       {'fg': s:medium_gray})
call s:h('FoldColumn',   {'fg': s:bg_subtle})
call s:h('DiffAdd',      {'fg': s:green})
call s:h('DiffDelete',   {'fg': s:red})
call s:h('DiffChange',   {'fg': s:yellow})
call s:h('DiffText',     {'gui': 'underline', 'cterm': 'underline',
            \             'sp': s:dark_yellow, 'fg': s:dark_yellow})
call s:h('SignColumn',   {'fg': s:accent})
call s:h('SpellBad',     {'gui': 'undercurl', 'cterm': 'underline',
            \             'sp': s:red})
call s:h('SpellCap',     {'gui': 'undercurl', 'cterm': 'underline',
            \             'sp': s:light_green})
call s:h('SpellRare',    {'gui': 'undercurl', 'cterm': 'underline',
            \             'sp': s:pink})
call s:h('SpellLocal',   {'gui': 'undercurl', 'cterm': 'underline',
            \             'sp': s:dark_green})

call s:h('Pmenu',        {'fg': s:norm, 'bg': s:bg_most_subtle})
hi! link PmenuSel   Search
hi! link PmenuThumb Search
hi! link PmenuSbar  Pmenu

call s:h('TabLine',      {'fg': s:norm_subtle, 'bg': s:bg_most_subtle})
hi! link TabLineSel Search
hi! link TabLineFill TabLine

call s:h('ColorColumn',  {'bg': s:bg_most_subtle})
call s:h('CursorLine',   {'bg': s:bg_most_subtle})
hi! link CursorColumn CursorLine

" Neovim: {{{1
call s:h('FloatBorder',  {'fg': s:bg_subtle, 'bg': s:bg_most_subtle})

" vim.diagnostic
call s:h('DiagnosticError', {'fg': s:red})
call s:h('DiagnosticWarn',  {'fg': s:yellow})
call s:h('DiagnosticHint',  {'fg': s:blue})
hi! link DiagnosticInfo Normal

call s:h('DiagnosticUnderlineError', {'gui': 'undercurl', 'cterm': 'underline',
            \                         'fg': s:red, 'sp': s:red})
call s:h('DiagnosticUnderlineWarn',  {'gui': 'undercurl', 'cterm': 'underline',
            \                         'fg': s:yellow, 'sp': s:yellow})
call s:h('DiagnosticUnderlineHint',  {'gui': 'undercurl', 'cterm': 'underline',
            \                         'sp': s:blue})
call s:h('DiagnosticUnderlineInfo',  {'gui': 'undercurl', 'cterm': 'underline',
            \                         'sp': s:norm})

" vim.lsp
call s:h('LspSignatureActiveParameter', {'fg': s:accent})

" Standard Plugins: {{{1
" matchparen.vim
call s:h('MatchParen',        {'bg': s:bg_subtle, 'fg': s:norm})

" help.vim
call s:h('helpHyperTextJump', {'fg': s:blue})

" diff.vim
hi! link diffAdded   DiffAdd
hi! link diffChanged DiffChange
hi! link diffRemoved DiffDelete

" Other Plugins: {{{1
" nvim-treesitter
hi! link TSConstBuiltin Constant
hi! link TSDanger Todo
