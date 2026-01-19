--- Slim, low-distraction colour scheme based on Selenized (Solarized variant),
--- with adjustments. https://github.com/jan-warchol/selenized

local api = vim.api

vim.cmd.highlight "clear"
vim.o.background = "dark"
vim.g.colors_name = "seanarized"

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

-- Palette {{{1
local p = setmetatable({
  -- Backgrounds
  bg0_float = { 0x0c323c, 16 },
  bg0 = { 0x103c48, 237 }, -- bg_0
  bg1 = { 0x14424f, 238 }, -- Mid-step
  bg2 = { 0x184956, 239 }, -- bg_1
  bg3 = { 0x22525f, 240 }, -- Mid-step
  bg4 = { 0x2d5b69, 241 }, -- bg_2
  bg5 = { 0x3e6774, 242 }, -- Mid-step toward dim_0
  bg_statusline0 = { 0x12404d, 237 },
  bg_statusline1 = { 0x244f5e, 241 },

  -- Foregrounds
  fg0 = { 0xadbcbc, 250 }, -- fg_0
  fg1 = { 0x72898f, 245 }, -- dim_0

  -- Accents
  yellow = { 0xdbb32d, 178 },
  orange = { 0xed8649, 208 },
  red = { 0xfa5750, 203 },
  magenta = { 0xf275be, 211 },
  violet = { 0xaf88eb, 141 },
  blue = { 0x4695f7, 33 },
  cyan = { 0x41c7b9, 37 },
  green = { 0x75b938, 107 },

  -- Bright Accents
  br_yellow = { 0xebc13d, 220 },
  br_orange = { 0xfd9456, 209 },
  br_red = { 0xff665c, 203 },
  br_magenta = { 0xff84cd, 212 },
  br_violet = { 0xbd96fa, 147 },
  br_blue = { 0x58a3ff, 39 },
  br_cyan = { 0x53d6c7, 79 },
  br_green = { 0x84c747, 113 },

  -- Diff
  bg_diff_red = { 0x3a2023, 52 },
  bg_diff_green = { 0x20321a, 22 },
  bg_diff_blue = { 0x1a3040, 24 },

  pure_black = { 0x000000, 16 },
}, p_mt)

local syn_p = setmetatable({
  comment = p.fg1,
  fn = p.br_blue,
  constant = p.fg0,
  string = p.green,
  type = p.br_violet,
}, p_mt)

-- Terminal buffers (:h terminal-config) {{{1
hl_term {
  p.bg2,
  p.red,
  p.green,
  p.yellow,
  p.blue,
  p.magenta,
  p.cyan,
  p.fg1,
  p.bg4,
  p.br_red,
  p.br_green,
  p.br_yellow,
  p.br_blue,
  p.br_magenta,
  p.br_cyan,
  p.fg0,
}

-- Editor groups (:h highlight-groups) {{{1
hl("ColorColumn", { bg = p.bg2 })
hl("Conceal", "Comment")
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
hl("EndOfBuffer", { fg = p.bg4 })
hl("TermCursor", "Cursor")
hl("OkMsg", { fg = p.green })
hl("WarningMsg", { fg = p.yellow })
hl("ErrorMsg", { fg = p.red })
hl("StderrMsg", "ErrorMsg")
hl("StdoutMsg", "Normal")
hl("WinSeparator", { fg = p.bg5 })
hl("Folded", { fg = p.fg1, bg = p.bg2 })
hl("FoldColumn", { fg = p.bg5 })
hl("SignColumn", { fg = p.fg0 })
hl("IncSearch", { fg = p.bg0, bg = p.magenta })
hl("Substitute", "Search")
hl("LineNr", { fg = p.bg5 })
hl("LineNrAbove", "LineNr")
hl("LineNrBelow", "LineNrAbove")
hl("CursorLineNr", { fg = p.cyan, bg = p.bg1 })
hl("CursorLineFold", "FoldColumn")
hl("CursorLineSign", "SignColumn")
hl("MatchParen", { fg = p.magenta, bold = true })
hl("ModeMsg", { fg = p.fg0, bold = true })
hl("MsgArea", "Normal")
hl("MsgSeparator", "StatusLine")
hl("MoreMsg", "ModeMsg")
hl("NonText", { fg = p.bg5 })
hl("Normal", { fg = p.fg0, bg = p.bg0 })
hl("NormalFloat", { bg = p.bg0_float })
hl("FloatBorder", "NormalFloat")
hl("FloatShadow", { bg = p.pure_black, blend = 80 })
hl("FloatShadowThrough", "FloatShadow")
hl("FloatTitle", "FloatBorder")
hl("FloatFooter", "FloatTitle")
hl("NormalNC", "Normal")
hl("Pmenu", { fg = p.fg0, bg = p.bg3 })
hl("PmenuSel", { fg = p.bg2, bg = p.fg1 })
hl("PmenuKind", { fg = p.fg1 })
hl("PmenuKindSel", "PmenuSel")
hl("PmenuExtra", { fg = p.green })
hl("PmenuExtraSel", "PmenuSel")
hl("PmenuSbar", { bg = p.bg2 })
hl("PmenuThumb", { bg = p.fg0 })
hl("PmenuMatch", { bold = true })
hl("PmenuMatchSel", { bold = true })
hl("PmenuBordeblue", "FloatBorder")
hl("PmenuShadow", "FloatShadow")
hl("PmenuShadowThrough", "PmenuShadow")
hl("ComplMatchIns", {})
hl("PreInsert", "Added")
hl("ComplHint", { fg = p.fg1 })
hl("ComplHintMore", { fg = p.fg1, bold = true })
hl("Question", "Title")
hl("QuickFixLine", { bg = p.bg2 })
hl("Search", { fg = p.bg0, bg = p.green })
hl("SnippetTabstop", "Visual")
hl("SnippetTabstopActive", "SnippetTabstop")
hl("SpecialKey", "SpecialChar")
hl("SpellBad", { sp = p.red, undercurl = true })
hl("SpellCap", { sp = p.blue, undercurl = true })
hl("SpellLocal", { sp = p.cyan, undercurl = true })
hl("SpellRare", { sp = p.violet, undercurl = true })
hl("StatusLine", { fg = p.fg0, bg = p.bg_statusline1 })
hl("StatusLineNC", { fg = p.fg1, bg = p.bg_statusline0 })
hl("StatusLineTerm", "StatusLine")
hl("StatusLineTermNC", "StatusLineNC")
hl("TabLine", "StatusLineNC")
hl("TabLineFill", "StatusLineNC")
hl("TabLineSel", "StatusLine")
hl("Title", { fg = p.fg0, bold = true })
hl("Visual", { bg = p.bg3 })
hl("VisualNOS", "Visual")
hl("Whitespace", { fg = p.bg4 })
hl("WildMenu", "Visual")
hl("WinBar", "TabLineSel")
hl("WinBarNC", "TabLine")
-- hl("Menu", "Pmenu") -- Unused
-- hl("Scrollbar", "PmenuSbar") -- Unused
-- hl("Tooltip", "Pmenu") -- Unused

-- Syntax groups (:h group-name) {{{1
hl("Comment", { fg = syn_p.comment })
hl("Constant", { fg = syn_p.constant })
hl("String", { fg = syn_p.string })
hl("Character", "String")
hl("Number", "Constant")
hl("Boolean", "Constant")
hl("Float", "Number")
hl("Identifier", { fg = p.fg0 })
hl("Function", { fg = syn_p.fn })
hl("Statement", "Keyword")
hl("Conditional", "Keyword")
hl("Repeat", "Keyword")
hl("Label", "Keyword")
hl("Operator", { fg = p.fg0 })
hl("Keyword", { fg = p.fg0, bold = true })
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
hl("DiagnosticHint", { fg = p.violet })
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
hl("DiagnosticUnderlineHint", { sp = p.violet, undercurl = true })
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
-- Can refer to calls, but links @function by default, which is for definitions.
hl("@lsp.type.function", "Function")
-- Typically it's more useful to guess a more specific group based on where the
-- macro is being used. May still be useful for combined highlights, though.
hl("@lsp.type.macro", {})
-- Ensures the signs of numbers still use @constant.
hl("@lsp.type.operator", {})

-- LSP other groups (:h lsp-highlight) {{{1
hl("LspReferenceText", { bg = p.bg2 })
hl("LspReferenceRead", "LspReferenceText")
hl("LspReferenceWrite", "LspReferenceText")
hl("LspReferenceTarget", "LspReferenceText")
hl("LspInlayHint", "NonText")
hl("LspCodeLens", { fg = p.fg1 })
hl("LspCodeLensSeparator", "LspCodeLens")
hl("LspSignatureActiveParameter", "LspReferenceText")

-- syntax/vim.vim overrides {{{1
hl("vimCommentTitle", "SpecialComment")
hl("vimFunctionName", "Function")
hl("vimUserFunc", "Function")

-- syntax/lua.vim overrides {{{1
hl("luaFunction", "Keyword")
hl("luaTable", "Delimiter")

-- copilot.vim {{{1
hl("CopilotSuggestion", "ComplHint")

-- fzf-lua {{{1
vim.g.fzf_colors = {
  ["hl"] = { "bg", "Search" },
  ["hl+"] = { "bg", "IncSearch" },
}

-- }}}1
-- vim: fdm=marker
