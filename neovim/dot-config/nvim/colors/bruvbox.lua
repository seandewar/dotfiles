--- Slim, somewhat minimalist colour scheme based on Gruvbox Material:
--- https://github.com/sainnhe/gruvbox-material

local api = vim.api

vim.cmd.highlight "clear"
vim.g.colors_name = "bruvbox"

-- Helpers {{{1
local function hl(name, val)
  if type(val) == "string" then
    val = { link = val }
  else
    assert(type(val) == "table")
    if type(val.fg) == "table" then
      local color = val.fg
      val.fg = color[1]
      val.ctermfg = color[2]
    end
    if type(val.bg) == "table" then
      local color = val.bg
      val.bg = color[1]
      val.ctermbg = color[2]
    end
    if type(val.sp) == "table" then
      val.sp = val.sp[1]
    end
  end
  return api.nvim_set_hl(0, name, val)
end

local function hl_term(colors)
  assert(#colors == 16)
  for i, color in ipairs(colors) do
    vim.g["terminal_color_" .. (i - 1)] = ("#%x"):format(color[1])
  end
end

local p_mt = { -- To catch bugs.
  __index = function(t, k)
    local v = rawget(t, k)
    if v == nil then
      error("Invalid key: " .. k)
    end
    return v
  end,
}

-- Palettes {{{1
local dark_p = setmetatable({ -- Uses hard contrast.
  bg_dim = { 0x141617, 232 },
  bg0 = { 0x1d2021, 234 },
  bg1 = { 0x282828, 235 },
  bg2 = { 0x282828, 235 },
  bg3 = { 0x3c3836, 237 },
  bg4 = { 0x3c3836, 237 },
  bg5 = { 0x504945, 239 },
  bg_statusline0 = { 0x282828, 235 },
  bg_statusline1 = { 0x32302f, 235 },
  bg_diff_red = { 0x3c1f1e, 52 },
  bg_diff_green = { 0x32361a, 22 },
  bg_diff_blue = { 0x0d3138, 17 },
  bg_current_word = { 0x32302f, 236 },

  fg0 = { 0xd4be98, 223 },
  fg1 = { 0xddc7a1, 223 },
  red = { 0xea6962, 167 },
  orange = { 0xe78a4e, 208 },
  yellow = { 0xd8a657, 214 },
  green = { 0xa9b665, 142 },
  aqua = { 0x89b482, 108 },
  blue = { 0x7daea3, 109 },
  purple = { 0xd3869b, 175 },

  gray0 = { 0x7c6f64, 243 },
  gray1 = { 0x928374, 245 },
  gray2 = { 0xa89984, 246 },
}, p_mt)

local light_p = setmetatable({ -- Uses soft contrast.
  bg_dim = { 0xebdbb2, 223 },
  bg0 = { 0xf2e5bc, 228 },
  bg1 = { 0xeddeb5, 223 },
  bg2 = { 0xebdbb2, 228 },
  bg3 = { 0xe6d5ae, 223 },
  bg4 = { 0xdac9a5, 250 },
  bg5 = { 0xd5c4a1, 250 },
  bg_statusline0 = { 0xebdbb2, 223 },
  bg_statusline1 = { 0xebdbb2, 223 },
  bg_diff_red = { 0xf7d9b9, 217 },
  bg_diff_green = { 0xdfe1b4, 194 },
  bg_diff_blue = { 0xdbddbf, 117 },
  bg_current_word = { 0xebdbb2, 227 },

  fg0 = { 0x654735, 237 },
  fg1 = { 0x4f3829, 237 },
  red = { 0xc14a4a, 88 },
  orange = { 0xc35e0a, 130 },
  yellow = { 0xb47109, 136 },
  green = { 0x6c782e, 100 },
  aqua = { 0x4c7a5d, 165 },
  blue = { 0x45707a, 24 },
  purple = { 0x945e80, 96 },

  gray0 = { 0xa89984, 246 },
  gray1 = { 0x928374, 245 },
  gray2 = { 0x7c6f64, 243 },
}, p_mt)

local is_dark = vim.o.background == "dark"
local p = is_dark and dark_p or light_p
p.pure_black = { 0x000000, 16 }

local syn_p = setmetatable({
  comment = p.gray1,
  fn = p.aqua,
  kw = p.red,
  number = p.purple,
  string = p.green,
  type = p.yellow,
}, p_mt)

-- Terminal buffers (:h terminal-config) {{{1
-- Same colour is used for most of the "bright" (8-15) colours.
hl_term {
  is_dark and p.bg0 or p.fg0,
  p.red,
  p.green,
  p.yellow,
  p.blue,
  p.purple,
  p.aqua,
  is_dark and p.gray2 or p.gray0,
  is_dark and p.gray0 or p.gray2,
  p.red,
  p.green,
  p.yellow,
  p.blue,
  p.purple,
  p.aqua,
  is_dark and p.fg0 or p.bg0,
}

-- Editor groups (:h highlight-groups) {{{1
hl("ColorColumn", { bg = p.bg2 })
hl("Conceal", { fg = p.bg5 })
hl("CurSearch", "IncSearch")
hl("Cursor", { fg = "bg", bg = "fg" })
hl("lCursor", "Cursor")
hl("CursorIM", "Cursor")
hl("CursorColumn", "CursorLine")
hl("CursorLine", { bg = p.bg1 })
hl("Directory", "String")
hl("DiffAdd", { bg = p.bg_diff_green })
hl("DiffChange", { bg = p.bg_diff_blue })
hl("DiffDelete", { bg = p.bg_diff_red })
hl("DiffText", { fg = p.bg0, bg = p.blue })
hl("DiffTextAdd", "DiffText")
hl("EndOfBuffer", { fg = p.bg5 })
hl("TermCursor", "Cursor")
hl("OkMsg", { fg = p.green })
hl("WarningMsg", { fg = p.yellow })
hl("ErrorMsg", { fg = p.red })
hl("StderrMsg", "ErrorMsg")
hl("StdoutMsg", "Normal")
hl("WinSeparator", { fg = p.bg5 })
hl("Folded", { fg = p.gray1, bg = p.bg2 })
hl("FoldColumn", { fg = p.bg5 })
hl("SignColumn", { fg = p.fg0 })
hl("IncSearch", { fg = p.bg0, bg = p.red })
hl("Substitute", "Search")
hl("LineNr", { fg = p.bg5 })
hl("LineNrAbove", "LineNr")
hl("LineNrBelow", "LineNrAbove")
hl("CursorLineNr", { fg = p.gray1, bg = p.bg1 })
hl("CursorLineFold", "FoldColumn")
hl("CursorLineSign", "SignColumn")
hl("MatchParen", { bg = p.bg4 })
hl("ModeMsg", { fg = p.fg0, bold = true })
hl("MsgArea", "Normal")
hl("MsgSeparator", "StatusLine")
hl("MoreMsg", "ModeMsg")
hl("NonText", { fg = p.bg5 })
hl("Normal", { fg = p.fg0, bg = p.bg0 })
hl("NormalFloat", { bg = p.bg_dim })
hl("FloatBorder", "NormalFloat")
hl("FloatShadow", { bg = p.pure_black, blend = 80 })
hl("FloatShadowThrough", "FloatShadow")
hl("FloatTitle", "FloatBorder")
hl("FloatFooter", "FloatTitle")
hl("NormalNC", "Normal")
hl("Pmenu", { fg = p.fg1, bg = p.bg3 })
hl("PmenuSel", { fg = p.bg3, bg = p.gray2 })
hl("PmenuKind", { fg = p.green, bg = p.bg3 })
hl("PmenuKindSel", "PmenuSel")
hl("PmenuExtra", { fg = p.gray2, bg = p.bg3 })
hl("PmenuExtraSel", "PmenuSel")
hl("PmenuSbar", { bg = p.bg3 })
hl("PmenuThumb", { bg = p.gray0 })
hl("PmenuMatch", { bold = true })
hl("PmenuMatchSel", { bold = true })
hl("PmenuBorder", "FloatBorder")
hl("PmenuShadow", "FloatShadow")
hl("PmenuShadowThrough", "PmenuShadow")
hl("ComplMatchIns", {})
hl("PreInsert", "Added")
hl("ComplHint", { fg = p.gray1 })
hl("ComplHintMore", { fg = p.gray1, bold = true })
hl("Question", "Title")
hl("QuickFixLine", { fg = p.purple, bold = true })
hl("Search", { fg = p.bg0, bg = p.green })
hl("SnippetTabstop", "Visual")
hl("SnippetTabstopActive", "SnippetTabstop")
hl("SpecialKey", "SpecialChar")
hl("SpellBad", { sp = p.red, undercurl = true })
hl("SpellCap", { sp = p.blue, undercurl = true })
hl("SpellLocal", { sp = p.aqua, undercurl = true })
hl("SpellRare", { sp = p.purple, undercurl = true })
hl("StatusLine", { fg = p.fg1, bg = p.bg_statusline1 })
hl("StatusLineNC", { fg = p.gray1, bg = p.bg_statusline0 })
hl("StatusLineTerm", "StatusLine")
hl("StatusLineTermNC", "StatusLineNC")
hl("TabLine", "StatusLineNC")
hl("TabLineFill", "StatusLineNC")
hl("TabLineSel", "StatusLine")
hl("Title", { fg = p.fg0, bold = true })
hl("Visual", { bg = p.bg3 })
hl("VisualNOS", "Visual")
hl("Whitespace", { fg = p.bg5 })
hl("WildMenu", "Visual")
hl("WinBar", "TabLineSel")
hl("WinBarNC", "TabLine")
-- hl("Menu", "Pmenu") -- Unused
-- hl("Scrollbar", "PmenuSbar") -- Unused
-- hl("Tooltip", "Pmenu") -- Unused

-- Syntax groups (:h group-name) {{{1
hl("Comment", { fg = syn_p.comment })
hl("Constant", "Identifier")
hl("String", { fg = syn_p.string })
hl("Character", "String")
hl("Number", { fg = syn_p.number })
hl("Boolean", "Number")
hl("Float", "Number")
hl("Identifier", { fg = p.fg0 })
hl("Function", { fg = syn_p.fn })
hl("Statement", "Keyword")
hl("Conditional", "Keyword")
hl("Repeat", "Keyword")
hl("Label", "Keyword")
hl("Operator", { fg = p.fg0 })
hl("Keyword", { fg = syn_p.kw })
hl("Exception", "Keyword")
hl("PreProc", "Keyword")
hl("Include", "PreProc")
hl("Define", "PreProc")
hl("Macro", "PreProc")
hl("PreCondit", "PreProc")
hl("Type", { fg = syn_p.type })
hl("StorageClass", "Keyword")
hl("Structure", "Keyword")
hl("Typedef", "Type")
hl("Special", { fg = p.fg0 })
hl("SpecialChar", { fg = syn_p.string, bold = true })
hl("Tag", "Special")
hl("Delimiter", { fg = p.fg0 })
hl("SpecialComment", { fg = syn_p.comment, bold = true })
hl("Debug", "Identifier")
hl("Underlined", { underline = true })
hl("Ignore", "Comment")
hl("Error", { fg = p.red })
hl("Todo", "SpecialComment")
hl("Added", { fg = p.green })
hl("Changed", { fg = p.blue })
hl("Removed", { fg = p.red })

-- Diagnostic groups (:h diagnostic-highlights) {{{1
hl("DiagnosticError", { fg = p.red })
hl("DiagnosticWarn", { fg = p.yellow })
hl("DiagnosticInfo", { fg = p.blue })
hl("DiagnosticHint", { fg = p.purple })
hl("DiagnosticOk", { fg = p.green })
hl("DiagnosticVirtualTextError", "DiagnosticError")
hl("DiagnosticVirtualTextWarn", "DiagnosticWarn")
hl("DiagnosticVirtualTextInfo", "DiagnosticInfo")
hl("DiagnosticVirtualTextHint", "DiagnosticHint")
hl("DiagnosticVirtualTextOk", "DiagnosticOk")
hl("DiagnosticVirtualLinesError", "DiagnosticVirtualTextError")
hl("DiagnosticVirtualLinesWarn", "DiagnosticVirtualTextWarn")
hl("DiagnosticVirtualLinesInfo", "DiagnosticVirtualTextInfo")
hl("DiagnosticVirtualLinesHint", "DiagnosticVirtualTextHint")
hl("DiagnosticVirtualLinesOk", "DiagnosticVirtualTextOk")
hl("DiagnosticUnderlineError", { sp = p.red, undercurl = true })
hl("DiagnosticUnderlineWarn", { sp = p.yellow, undercurl = true })
hl("DiagnosticUnderlineInfo", { sp = p.blue, undercurl = true })
hl("DiagnosticUnderlineHint", { sp = p.purple, undercurl = true })
hl("DiagnosticUnderlineOk", { sp = p.green, undercurl = true })
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
hl("DiagnosticDeprecated", { sp = p.fg0, strikethrough = true })
hl("DiagnosticUnnecessary", "Comment")

-- Tree-sitter groups (:h treesitter-highlight-groups) {{{1
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

hl("@comment.error", { fg = p.red, bold = true })
hl("@comment.warning", { fg = p.yellow, bold = true })
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
hl("@number.comment", "Comment")
hl("@punctuation.bracket.comment", "Comment")
hl("@punctuation.delimiter.comment", "Comment")

-- p, p++ parser overrides
hl("@keyword.import.p", "Include")
hl("@keyword.import.cpp", "Include")

-- Lua parser overrides
hl("@constructor.lua", {})

-- LSP semantic groups (:h lsp-semantic-highlight) {{{1
hl("@lsp.type.function", "Function")
hl("@lsp.type.macro", {})

-- LSP other groups (:h lsp-highlight) {{{1
hl("LspReferenceText", { bg = p.bg_current_word })
hl("LspReferenceRead", "LspReferenceText")
hl("LspReferenceWrite", "LspReferenceText")
hl("LspReferenceTarget", "LspReferenceText")
hl("LspInlayHint", "NonText")
hl("LspCodeLens", { fg = p.gray1 })
hl("LspCodeLensSeparator", "LspCodeLens")
hl("LspSignatureActiveParameter", "LspReferenceText")

-- syntax/vim.vim overrides {{{1
hl("vimCommentTitle", "SpecialComment")

-- syntax/lua.vim overrides {{{1
hl("luaFunction", "Keyword")
hl("luaTable", "Delimiter")

-- copilot.vim {{{1
hl("CopilotSuggestion", "ComplHint")

-- fzf-lua {{{1
vim.g.fzf_colors = {
  ["hl"] = { "fg", "String" },
  ["hl+"] = { "fg", "String" },
}

-- }}}1
-- vim: fdm=marker
