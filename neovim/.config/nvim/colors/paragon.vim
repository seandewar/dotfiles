" Name:       paragon.vim
" Version:    0.1.0
" Maintainer: Sean Dewar <https://github.com/seandewar>
" License:    The MIT License (MIT)
"
" A minimal colour scheme for Vim and Neovim based on paramount.vim:
" https://github.com/owickstrom/vim-colors-paramount
"
" Unlike the name "paramount", "paragon" has no real meaning.
" The name was chosen because it also begins with a "p".
" However, @3N4N came up with a great excuse for me:
"
" > Well paragon means people with high virtue.
" > It's similar, like, in a metaphorical sense. :)

highlight clear
let g:colors_name = 'paragon'

let s:white         = #{gui: '#f1f1f1', cterm: '15' }
let s:actual_white  = #{gui: '#ffffff', cterm: '231'}
let s:medium_gray   = #{gui: '#767676', cterm: '243'}
let s:light_gray    = #{gui: '#a8a8a8', cterm: '248'}
let s:lighter_gray  = #{gui: '#c6c6c6', cterm: '251'}
let s:lightest_gray = #{gui: '#eeeeee', cterm: '255'}
let s:black         = #{gui: '#000000', cterm: '232'}
let s:light_black   = #{gui: '#262626', cterm: '235'}
let s:subtle_black  = #{gui: '#303030', cterm: '236'}
let s:lighter_black = #{gui: '#4e4e4e', cterm: '239'}
let s:light_red     = #{gui: '#e22633', cterm: '1'  }
let s:dark_red      = #{gui: '#c10714', cterm: '1'  }
let s:light_green   = #{gui: '#5fd7a7', cterm: '10' }
let s:dark_green    = #{gui: '#10a778', cterm: '2'  }
let s:light_yellow  = #{gui: '#ffff87', cterm: '228'}
let s:dark_yellow   = #{gui: '#a89c14', cterm: '3'  }
let s:light_orange  = #{gui: '#d7875f', cterm: '173'}
let s:dark_orange   = #{gui: '#af5f00', cterm: '130'}
let s:blue          = #{gui: '#00afff', cterm: '39' }
let s:pink          = #{gui: '#fb007a', cterm: '9'  }

let s:background = &background
if &background ==# 'dark'
    let s:red            = s:light_red
    let s:green          = s:light_green
    let s:yellow         = s:light_yellow

    let s:accent         = s:light_orange
    let s:norm           = s:lighter_gray
    let s:norm_subtle    = s:medium_gray
    let s:bg             = s:black
    let s:bg_subtle      = s:lighter_black
    let s:bg_very_subtle = s:subtle_black
    let s:bg_most_subtle = s:light_black
else
    let s:red            = s:dark_red
    let s:green          = s:dark_green
    let s:yellow         = s:dark_yellow

    let s:accent         = s:dark_orange
    let s:norm           = s:black
    let s:norm_subtle    = s:light_black
    let s:bg             = s:actual_white
    let s:bg_subtle      = s:medium_gray
    let s:bg_very_subtle = s:light_gray
    let s:bg_most_subtle = s:white
endif
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

call s:h('Normal', #{fg: s:norm})
" Restore &background's value in case changing Normal changed &background.
" (`:help :hi-normal-cterm`)
if &background !=# s:background
    let &background = s:background
endif

" Syntax Highlights: (ordered as in `:h group-name`) {{{1
call s:h('Comment', #{fg: s:bg_subtle, gui: 'italic', cterm: 'italic'})

call s:h('Constant', #{fg: s:accent})
highlight! link String Constant
highlight! link Character Constant
highlight! link Number Constant
highlight! link Boolean Constant
highlight! link Float Constant

highlight! link Identifier Normal
highlight! link Function Identifier

call s:h('Statement', #{fg: s:norm_subtle})
highlight! link Conditonal Statement
highlight! link Repeat Statement
highlight! link Label Statement
call s:h('Operator', #{fg: s:norm_subtle, cterm: 'bold', gui: 'bold'})
highlight! link Keyword Statement
highlight! link Exception Statement

call s:h('PreProc', #{fg: s:norm_subtle})
highlight! link Include PreProc
highlight! link Define PreProc
highlight! link PreCondit PreProc

highlight! link Type Normal
highlight! link StorageClass Keyword
highlight! link Structure Keyword
highlight! link Typedef Type

call s:h('Special', #{fg: s:norm_subtle})
call s:h('SpecialChar', #{fg: s:accent, gui: 'bold'})
call s:h('Tag', #{fg: s:blue})
highlight! link Delimiter Special
call s:h('SpecialComment', #{fg: s:norm_subtle, gui: 'italic', cterm: 'italic'})
call s:h('Debug', #{fg: s:norm_subtle})

call s:h('Underlined', #{fg: s:norm, gui: 'underline', cterm: 'underline'})
call s:h('Error', #{fg: s:actual_white, bg: s:red, cterm: 'bold'})
highlight! link Todo SpecialComment

" Other Highlights: {{{1
call s:h('NonText', #{fg: s:bg_subtle, bg: s:bg_most_subtle})
call s:h('EndOfBuffer', #{fg: s:bg_subtle})
call s:h('Ignore', #{fg: s:bg_subtle})
highlight! link Conceal Ignore
highlight! link Whitespace Ignore
call s:h('SpecialKey', #{fg: s:blue, gui: 'italic', cterm: 'italic'})

call s:h('Visual', #{fg: s:blue, bg: s:subtle_black})
call s:h('VisualNOS', #{fg: s:white, bg: s:bg_subtle})

call s:h('Search', #{fg: s:accent_contrast, bg: s:accent})
call s:h('IncSearch', #{fg: s:light_black, bg: s:blue})
highlight! link CurSearch IncSearch

call s:h('DiffAdd', #{fg: s:green})
call s:h('DiffDelete', #{fg: s:red})
call s:h('DiffChange', #{fg: s:yellow})
call s:h('DiffText', #{gui: 'underline', cterm: 'underline', sp: s:dark_yellow,
            \          fg: s:dark_yellow})

call s:h('SpellBad', #{gui: 'undercurl', cterm: 'underline', sp: s:red})
call s:h('SpellCap', #{gui: 'undercurl', cterm: 'underline', sp: s:light_green})
call s:h('SpellRare', #{gui: 'undercurl', cterm: 'underline', sp: s:pink})
call s:h('SpellLocal', #{gui: 'undercurl', cterm: 'underline',
            \            sp: s:dark_green})

call s:h('MoreMsg', #{fg: s:medium_gray, gui: 'bold', cterm: 'bold'})
highlight! link ModeMsg MoreMsg
call s:h('WarningMsg', #{fg: s:yellow})
call s:h('ErrorMsg', #{fg: s:red})
call s:h('Title', #{fg: s:norm_subtle})
call s:h('Question', #{fg: s:blue})
call s:h('Directory', #{fg: s:accent})

call s:h('CursorLine', #{bg: s:bg_most_subtle})
highlight! link CursorColumn CursorLine
call s:h('CursorLineNr', #{fg: s:accent, bg: s:bg_very_subtle})
call s:h('LineNr', #{fg: s:bg_subtle})

call s:h('ColorColumn', #{bg: s:bg_most_subtle})
call s:h('SignColumn', #{fg: s:accent})
call s:h('FoldColumn', #{fg: s:bg_subtle})
call s:h('Folded', #{fg: s:medium_gray})

call s:h('StatusLine', #{bg: s:bg_most_subtle})
call s:h('StatusLineNC', #{fg: s:norm_subtle, bg: s:bg_most_subtle})
call s:h('VertSplit', #{fg: s:bg_most_subtle})

call s:h('TabLine', #{fg: s:norm_subtle, bg: s:bg_most_subtle})
highlight! link TabLineSel Search
highlight! link TabLineFill TabLine

call s:h('WildMenu', #{fg: s:bg, bg: s:norm})

call s:h('Pmenu', #{fg: s:norm, bg: s:bg_most_subtle})
highlight! link PmenuSel Search
highlight! link PmenuThumb Search
highlight! link PmenuSbar Pmenu

" Standard Plugins: {{{1
" diff.vim
highlight! link diffAdded DiffAdd
highlight! link diffChanged DiffChange
highlight! link diffRemoved DiffDelete

" help.vim
highlight! link helpHyperTextJump Tag
highlight! link helpURL Underlined

" lua.vim
highlight! link luaFunction Keyword

" matchparen.vim
call s:h('MatchParen', #{fg: s:norm, bg: s:bg_subtle})

" rust.vim
highlight! link rustLifetime StorageClass
highlight! link rustModPath Identifier
highlight! link rustSelf Keyword

" vim.vim
highlight! link vimCommentString Comment
highlight! link vimHiBang Special
highlight! link vimOperParen Special

" zig.vim
highlight! link zigDummyVariable Special
highlight! link zigEscape SpecialChar
highlight! link zigMacro Keyword
highlight! link zigMultilineStringDelimiter String
highlight! link zigVarDecl Keyword
" }}}

if !has('nvim')
    finish
endif
" Neovim: {{{1
call s:h('FloatTitle', #{fg: s:norm, bg: s:bg_most_subtle})
call s:h('FloatBorder', #{fg: s:bg_subtle, bg: s:bg_most_subtle})

" vim.diagnostic
call s:h('DiagnosticError', #{fg: s:red})
call s:h('DiagnosticWarn', #{fg: s:yellow})
call s:h('DiagnosticHint', #{fg: s:blue})
highlight! link DiagnosticInfo Normal

call s:h('DiagnosticUnderlineError', #{gui: 'undercurl', cterm: 'underline',
            \                          sp: s:red})
call s:h('DiagnosticUnderlineWarn', #{gui: 'undercurl', cterm: 'underline',
            \                         sp: s:yellow})
call s:h('DiagnosticUnderlineHint', #{gui: 'undercurl', cterm: 'underline',
            \                         sp: s:blue})
call s:h('DiagnosticUnderlineInfo', #{gui: 'undercurl', cterm: 'underline',
            \                         sp: s:norm})

" vim.treesitter
highlight! link @conceal Conceal
highlight! link @constant.builtin Constant
highlight! link @constant.comment SpecialComment
highlight! link @function.macro Identifier
highlight! link @label Identifier
highlight! link @macro Identifier
highlight! link @structure Identifier
highlight! link @text.note Todo
highlight! link @text.reference Tag
highlight! link @type.qualifier Keyword
highlight! link @variable.builtin Special

highlight! link @label.help String
" Zig omg stop misusing these captures plz
highlight! link @attribute.zig Keyword

" vim.lsp
" These are linked to tree-sitter groups where applicable to make things easier.
highlight! link @lsp.type.boolean @boolean
highlight! link @lsp.type.builtinType @type
highlight! link @lsp.type.character @character
highlight! link @lsp.type.class @type
highlight! link @lsp.type.decorator @function
highlight! link @lsp.type.enum @type
highlight! link @lsp.type.enumMember @constant
highlight! link @lsp.type.escapeSequence @string.escape
highlight! link @lsp.type.function @function
highlight! link @lsp.type.generic Normal
highlight! link @lsp.type.interface @type
highlight! link @lsp.type.keyword @keyword
highlight! link @lsp.type.lifetime @storageclass.lifetime
highlight! link @lsp.type.macro @macro
highlight! link @lsp.type.method @method
highlight! link @lsp.type.namespace @namespace
highlight! link @lsp.type.number @constant
highlight! link @lsp.type.operator @operator
highlight! link @lsp.type.parameter @parameter
highlight! link @lsp.type.property @property
highlight! link @lsp.type.selfKeyword @keyword
highlight! link @lsp.type.selfTypeKeyword @keyword
highlight! link @lsp.type.string @string
highlight! link @lsp.type.struct @structure
highlight! link @lsp.type.type @type
highlight! link @lsp.type.typeAlias @type
highlight! link @lsp.type.typeParameter @type.definition
highlight! link @lsp.type.variable @variable

highlight! link @lsp.typemod.variable.constant @constant

call s:h('LspSignatureActiveParameter', #{fg: s:accent})

" vim: et tw=80 sw=4
