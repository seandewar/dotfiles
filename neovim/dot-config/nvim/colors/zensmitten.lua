--- Colour scheme based on zenwritten from the zenbones collection; slimmed down
--- and with personal touches.

local api = vim.api

vim.cmd.highlight "clear"
vim.o.background = "dark" -- Light mode not supported.
vim.g.colors_name = "zensmitten"

local function hl(name, val)
  if type(val) == "string" then
    val = { link = val }
  else
    assert(type(val) == "table")
    if type(val.fg) == "table" then
      local t = val.fg
      val.fg = t[1]
      val.ctermfg = t[2]
    end
    if type(val.bg) == "table" then
      local t = val.bg
      val.bg = t[1]
      val.ctermbg = t[2]
    end
  end

  return api.nvim_set_hl(0, name, val)
end

-- Palette {{{1
local p = {
  bg = 0x191919,
  fg = 0xbbbbbb,
  comment = 0x686868,
  string = 0x8bb4a9,
  number = 0xb48a95,
  delimiter = 0x7c7c7c,
  type = 0x9fa8ad,

  fg_error = 0xde6e7c,
  fg_warning = 0xb7a864,
  fg_info = 0x6099c0,
  fg_hint = 0xb279a7,
  fg_ok = 0x819b69,
  bg_error = 0x272020,
  bg_warning = 0x242320,
  bg_info = 0x202223,
  bg_hint = 0x252024,
  bg_ok = 0x212220,
  fg_diff_added = 0xb3f6c0,
  fg_diff_changed = 0x8cf8f7,
  fg_diff_removed = 0xffc0b9,
  bg_diff_added = 0x232d1a,
  bg_diff_changed = 0x1d2c36,
  bg_diff_removed = 0x3e2225,
  non_text = 0x555555,

  gutter = 0x616161,
  bg_statusline = 0x303030,
  bg_statusline_nc = 0x242424,
  bg_cursorline = 0x222222,
  bg_search = 0x65435e,
  bg_search_sel = 0xbf8fb5,
  bg_visual = 0x404040,
  bg_float = 0x0a0a0a,
  bg_shadow = 0x000000,
  bg_pmenu = 0x2c2c2c,
  bg_pmenu_sel = 0x444444,
  bg_pmenu_sbar = 0x595959,
  bg_pmenu_thumb = 0x848484,
}

-- Accessing a non-existent palette is almost certainly a bug.
setmetatable(p, {
  __index = function(t, k)
    local v = rawget(t, k)
    if v == nil then
      error("Invalid palette key: " .. k)
    end
    return v
  end,
})

-- }}}1

-- Editor groups (:h highlight-groups) {{{1

hl("ColorColumn", { bg = p.bg_statusline_nc })
hl("Conceal", { fg = p.comment })
hl("CurSearch", "IncSearch")
hl("Cursor", { fg = "bg", bg = "fg" })
hl("lCursor", "Cursor")
hl("CursorIM", "Cursor")
hl("CursorColumn", "CursorLine")
hl("CursorLine", { bg = p.bg_cursorline })
hl("Directory", { fg = p.fg, bold = true })
hl("DiffAdd", { bg = p.bg_diff_added })
hl("DiffChange", { bg = p.bg_diff_changed })
hl("DiffDelete", { bg = p.bg_diff_removed })
hl("DiffText", { fg = p.bg, bg = p.fg_diff_changed })
hl("DiffTextAdd", "DiffText")
hl("EndOfBuffer", "NonText")
hl("TermCursor", "Cursor")
hl("OkMsg", { fg = p.fg_ok })
hl("WarningMsg", { fg = p.fg_warning })
hl("ErrorMsg", { fg = p.fg_error })
hl("StderrMsg", "ErrorMsg")
hl("StdoutMsg", "Normal")
hl("WinSeparator", { fg = p.bg_statusline })
hl("Folded", { fg = p.gutter, bg = p.bg_statusline_nc })
hl("FoldColumn", { fg = p.gutter })
hl("SignColumn", { fg = p.gutter })
hl("IncSearch", { fg = p.bg, bg = p.bg_search_sel })
hl("Substitute", "Search")
hl("LineNr", { fg = p.gutter })
hl("LineNrAbove", "LineNr")
hl("LineNrBelow", "LineNrAbove")
hl("CursorLineNr", { fg = p.fg, bold = true })
hl("CursorLineFold", "FoldColumn")
hl("CursorLineSign", "SignColumn")
hl("MatchParen", "Search")
hl("ModeMsg", "Normal")
hl("MsgArea", "Normal")
hl("MsgSeparator", "StatusLine")
hl("MoreMsg", { fg = p.fg_info })
hl("NonText", { fg = p.non_text })
hl("Normal", { fg = p.fg, bg = p.bg })
hl("NormalFloat", { bg = p.bg_float })
hl("FloatBorder", "NormalFloat")
hl("FloatShadow", { bg = p.bg_shadow, blend = 80 })
hl("FloatShadowThrough", "FloatShadow")
hl("FloatTitle", "FloatBorder")
hl("FloatFooter", "FloatTitle")
hl("NormalNC", "Normal")
hl("Pmenu", { bg = p.bg_pmenu })
hl("PmenuSel", { bg = p.bg_pmenu_sel })
hl("PmenuKind", "Pmenu")
hl("PmenuKindSel", "PmenuSel")
hl("PmenuExtra", "Pmenu")
hl("PmenuExtraSel", "PmenuSel")
hl("PmenuSbar", { bg = p.bg_pmenu_sbar })
hl("PmenuThumb", { bg = p.bg_pmenu_thumb })
hl("PmenuMatch", { bold = true })
hl("PmenuMatchSel", { bold = true })
hl("PmenuBorder", "FloatBorder")
hl("PmenuShadow", "FloatShadow")
hl("PmenuShadowThrough", "PmenuShadow")
hl("ComplMatchIns", {})
hl("PreInsert", "Added")
hl("ComplHint", "NonText")
hl("ComplHintMore", "MoreMsg")
hl("Question", { fg = p.fg_ok })
hl("QuickFixLine", { bg = p.bg_statusline_nc })
hl("Search", { fg = p.fg, bg = p.bg_search })
hl("SnippetTabstop", "Visual")
hl("SnippetTabstopActive", "SnippetTabstop")
hl("SpecialKey", { fg = p.comment })
hl("SpellBad", { sp = p.fg_error, undercurl = true })
hl("SpellCap", { sp = p.fg_warning, undercurl = true })
hl("SpellLocal", { sp = p.fg_info, undercurl = true })
hl("SpellRare", { sp = p.fg_hint, undercurl = true })
hl("StatusLine", { fg = p.fg, bg = p.bg_statusline })
hl("StatusLineNC", { fg = p.comment, bg = p.bg_statusline_nc })
hl("StatusLineTerm", "StatusLine")
hl("StatusLineTermNC", "StatusLineNC")
hl("TabLine", "StatusLineNC")
hl("TabLineFill", "StatusLineNC")
hl("TabLineSel", "StatusLine")
hl("Title", { fg = p.fg, bold = true })
hl("Visual", { bg = p.bg_visual })
hl("VisualNOS", "Visual")
hl("Whitespace", "NonText")
hl("WildMenu", "Visual")
hl("WinBar", "TabLineSel")
hl("WinBarNC", "TabLine")
-- hl("Menu", "Pmenu") -- Unused
-- hl("Scrollbar", "PmenuSbar") -- Unused
-- hl("Tooltip", "Pmenu") -- Unused

-- Syntax groups (:h group-name) {{{1

hl("Comment", { fg = p.comment })
hl("Constant", "Identifier")
hl("String", { fg = p.string })
hl("Character", "String")
hl("Number", { fg = p.number })
hl("Boolean", "Constant")
hl("Float", "Number")
hl("Identifier", { fg = p.fg })
hl("Function", "Identifier")
hl("Statement", "Keyword")
hl("Conditional", "Keyword")
hl("Repeat", "Keyword")
hl("Label", "Keyword")
hl("Operator", { fg = p.fg })
hl("Keyword", { fg = p.fg, bold = true })
hl("Exception", "Keyword")
hl("PreProc", "Keyword")
hl("Include", "PreProc")
hl("Define", "PreProc")
hl("Macro", "PreProc")
hl("PreCondit", "PreProc")
hl("Type", { fg = p.type })
hl("StorageClass", "Keyword")
hl("Structure", "Keyword")
hl("Typedef", "Type")
hl("Special", { fg = p.fg })
hl("SpecialChar", { fg = p.string, bold = true })
hl("Tag", "Special")
hl("Delimiter", { fg = p.delimiter })
hl("SpecialComment", { fg = p.comment, bold = true })
hl("Debug", "Identifier")
hl("Underlined", { underline = true })
hl("Ignore", { fg = p.comment })
hl("Error", { fg = p.fg_error })
hl("Todo", "SpecialComment")
hl("Added", { fg = p.fg_diff_added })
hl("Changed", { fg = p.fg_diff_changed })
hl("Removed", { fg = p.fg_diff_removed })

-- Diagnostic groups (:h diagnostic-highlights) {{{1

hl("DiagnosticError", { fg = p.fg_error })
hl("DiagnosticWarn", { fg = p.fg_warning })
hl("DiagnosticInfo", { fg = p.fg_info })
hl("DiagnosticHint", { fg = p.fg_hint })
hl("DiagnosticOk", { fg = p.fg_ok })
hl("DiagnosticVirtualTextError", { fg = p.fg_error, bg = p.bg_error })
hl("DiagnosticVirtualTextWarn", { fg = p.fg_warning, bg = p.bg_warning })
hl("DiagnosticVirtualTextInfo", { fg = p.fg_info, bg = p.bg_info })
hl("DiagnosticVirtualTextHint", { fg = p.fg_hint, bg = p.bg_hint })
hl("DiagnosticVirtualTextOk", { fg = p.fg_ok, bg = p.bg_ok })
hl("DiagnosticVirtualLinesError", "DiagnosticVirtualTextError")
hl("DiagnosticVirtualLinesWarn", "DiagnosticVirtualTextWarn")
hl("DiagnosticVirtualLinesInfo", "DiagnosticVirtualTextInfo")
hl("DiagnosticVirtualLinesHint", "DiagnosticVirtualTextHint")
hl("DiagnosticVirtualLinesOk", "DiagnosticVirtualTextOk")
hl("DiagnosticUnderlineError", { sp = p.fg_error, undercurl = true })
hl("DiagnosticUnderlineWarn", { sp = p.fg_warning, undercurl = true })
hl("DiagnosticUnderlineInfo", { sp = p.fg_info, undercurl = true })
hl("DiagnosticUnderlineHint", { sp = p.fg_hint, undercurl = true })
hl("DiagnosticUnderlineOk", { sp = p.fg_ok, undercurl = true })
hl("DiagnosticFloatingError", "DiagnosticError")
hl("DiagnosticFloatingWarn", "DiagnosticWarn")
hl("DiagnosticFloatingInfo", "DiagnosticInfo")
hl("DiagnosticFloatingHint", "DiagnosticHint")
hl("DiagnosticFloatingOk", "DiagnosticOk")
hl("DiagnosticSignError", "DiagnosticError")
hl("DiagnosticSignWarn", "DiagnosticWarn")
hl("DiagnosticSignInfo", "DiagnosticInfo")
hl("DiagnosticSignHint", "DiagnosticHint")
hl("DiagnosticSignOk", "DiagnosticOk")
hl("DiagnosticDeprecated", { sp = p.comment, strikethrough = true })
hl("DiagnosticUnnecessary", { fg = p.comment })

-- Tree-sitter groups (:h treesitter-highlight-groups) {{{1
--
-- Although tree-sitter-style groups implement a fallback mechanism, we
-- explicitly define all standard groups instead.

hl("@variable", "Identifier")
hl("@variable.builtin", "@variable")
hl("@variable.parameter", "@variable")
hl("@variable.parameter.builtin", "@variable.parameter")
hl("@variable.member", "@variable")

hl("@constant", "Constant")
hl("@constant.builtin", "@constant")
hl("@constant.macro", "@constant")

hl("@module", "Identifier")
hl("@module.builtin", "@module")
hl("@label", "Identifier")

hl("@string", "String")
hl("@string.documentation", "@string")
hl("@string.regexp", "@string")
hl("@string.escape", "SpecialChar")
hl("@string.special", "@string")
hl("@string.special.symbol", "@string")
hl("@string.special.path", "@string")
hl("@string.special.url", "Underlined")

hl("@character", "Character")
hl("@character.special", "@operator")

hl("@boolean", "Boolean")
hl("@number", "Number")
hl("@number.float", "Float")

hl("@type", "Type")
hl("@type.builtin", "@type")
hl("@type.definition", "@type")

hl("@attribute", "Identifier")
hl("@attribute.builtin", "@attribute")
hl("@property", "Identifier")

hl("@function", "Function")
hl("@function.builtin", "@function.call")
hl("@function.call", "Function")
hl("@function.macro", "@function.call")

hl("@function.method", "@function")
hl("@function.method.call", "@function.call")

hl("@constructor", "Identifier")
hl("@operator", "Operator")

hl("@keyword", "Keyword")
hl("@keyword.coroutine", "@keyword")
hl("@keyword.function", "@keyword")
hl("@keyword.operator", "@keyword")
hl("@keyword.import", "@keyword")
hl("@keyword.type", "@keyword")
hl("@keyword.modifier", "StorageClass")
hl("@keyword.repeat", "Repeat")
hl("@keyword.return", "@keyword")
hl("@keyword.debug", "@keyword")
hl("@keyword.exception", "Exception")

hl("@keyword.conditional", "Conditional")
hl("@keyword.conditional.ternary", "@operator")

hl("@keyword.directive", "PreProc")
hl("@keyword.directive.define", "@keyword.directive")

hl("@punctuation", "Delimiter") -- Non-standard; used as a link target.
hl("@punctuation.delimiter", "@punctuation")
hl("@punctuation.bracket", "@punctuation")
hl("@punctuation.special", "@punctuation")

hl("@comment", "Comment")
hl("@comment.documentation", "@comment")

hl("@comment.error", { fg = p.fg_error, bold = true })
hl("@comment.warning", { fg = p.fg_warning, bold = true })
hl("@comment.todo", "SpecialComment")
hl("@comment.note", "SpecialComment")

hl("@markup.strong", { bold = true })
hl("@markup.italic", { italic = true })
hl("@markup.strikethrough", { strikethrough = true })
hl("@markup.underline", "Underlined")

hl("@markup.heading", "Title")
hl("@markup.heading.1", "@markup.heading")
hl("@markup.heading.2", "@markup.heading")
hl("@markup.heading.3", "@markup.heading")
hl("@markup.heading.4", "@markup.heading")
hl("@markup.heading.5", "@markup.heading")
hl("@markup.heading.6", "@markup.heading")

hl("@markup.quote", "Special")
hl("@markup.math", "Special")

hl("@markup.link", "Underlined")
hl("@markup.link.label", "@markup.link")
hl("@markup.link.url", "@markup.link")

hl("@markup.raw", "Special")
hl("@markup.raw.block", "@markup.raw")

hl("@markup.list", "Special")
hl("@markup.list.checked", "@markup.list")
hl("@markup.list.unchecked", "@markup.list")

hl("@diff.plus", "Added")
hl("@diff.minus", "Removed")
hl("@diff.delta", "Changed")

hl("@tag", "Tag")
hl("@tag.builtin", "@tag")
hl("@tag.attribute", "@tag")
hl("@tag.delimiter", "@tag")

-- Comment parser overrides
hl("@constant.comment", "Comment")
hl("@punctuation.bracket.comment", "Comment")
hl("@punctuation.delimiter.comment", "Comment")

-- C, C++ parser overrides
hl("@keyword.import.c", "Include")
hl("@keyword.import.cpp", "Include")

-- Lua parser overrides
hl("@constructor.lua", {})

-- LSP semantic groups (:h lsp-semantic-highlight) {{{1

hl("@lsp.type.function", "Function")
hl("@lsp.type.macro", {})
hl("@lsp.type.operator", {})

-- LSP other groups (:h lsp-highlight) {{{1

hl("LspReferenceText", { bg = p.bg_statusline_nc })
hl("LspReferenceRead", "LspReferenceText")
hl("LspReferenceWrite", "LspReferenceText")
hl("LspReferenceTarget", "LspReferenceText")
hl("LspInlayHint", "NonText")
hl("LspCodeLens", "NonText")
hl("LspCodeLensSeparator", "LspCodeLens")
hl("LspSignatureActiveParameter", "LspReferenceText")

-- syntax/vim.vim overrides {{{1

hl("vimCommentTitle", "SpecialComment")

-- syntax/lua.vim overrides {{{1

hl("luaFunction", "Keyword")
hl("luaTable", "Delimiter")

-- }}}1

-- vim: fdm=marker
