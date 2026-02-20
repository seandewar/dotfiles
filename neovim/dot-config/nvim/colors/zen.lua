--- Low-distraction colour scheme inspired by Kanagawa Paper:
--- https://github.com/thesimonho/kanagawa-paper.nvim

local api = vim.api

vim.cmd.highlight "clear"
vim.o.background = "dark"
vim.g.colors_name = "zen"

-- Helpers {{{1
local approx_cterm
do
  -- Doesn't include system colours (cterm 0-15) as they're commonly customized.
  local cterm_lut = {}

  -- 6x6x6 colour cube (cterm 16-231)
  local levels = { 0, 95, 135, 175, 215, 255 }
  for _, r in ipairs(levels) do
    for _, g in ipairs(levels) do
      for _, b in ipairs(levels) do
        table.insert(cterm_lut, { r, g, b })
      end
    end
  end
  -- Grayscale ramp (cterm 232-255)
  for i = 0, 23 do
    local c = 8 + (i * 10)
    table.insert(cterm_lut, { c, c, c })
  end
  assert(#cterm_lut == 256 - 16)

  approx_cterm = function(r8, g8, b8)
    local best_dist_sq = math.huge
    local best_lut_i

    for i, crgb8 in ipairs(cterm_lut) do
      local cr8, cg8, cb8 = unpack(crgb8)
      -- Calculate the squared redmean distance. Pick the closest cterm.
      -- Apparently still more accurate than the Euclidean distance when
      -- weighted to account for the distribution of cones in the human eye!
      local r_delta_sq = (r8 - cr8) ^ 2
      local g_delta_sq = (g8 - cg8) ^ 2
      local b_delta_sq = (b8 - cb8) ^ 2
      local r_mean = (r8 + cr8) * 0.5
      local dist_sq = (2 + r_mean / 256) * r_delta_sq
        + 4 * g_delta_sq
        + (2 + (255 - r_mean) / 256) * b_delta_sq

      if dist_sq < best_dist_sq then
        best_dist_sq = dist_sq
        best_lut_i = i
      end
    end
    return best_lut_i + 15
  end
end

--- https://bottosson.github.io/posts/oklab/
--- @param lightness perceived lightness (0-1)
--- @param chroma (typically 0-0.5, actually 0-inf)
--- @param hue (degrees)
local function oklch(lightness, chroma, hue)
  assert(lightness >= 0 and lightness <= 1 and chroma >= 0)
  -- Convert to OKLab.
  local h = math.rad(hue)
  local a = chroma * math.cos(h)
  local b = chroma * math.sin(h)

  -- Convert to LMS-like.
  local l = (lightness + 0.3963377774 * a + 0.2158037573 * b) ^ 3
  local m = (lightness - 0.1055613458 * a - 0.0638541728 * b) ^ 3
  local s = (lightness - 0.0894841775 * a - 1.2914855480 * b) ^ 3

  local function gamma(c)
    return c <= 0.0031308 and (c * 12.92)
      or (1.055 * (c ^ 0.4166666667) - 0.055)
  end
  -- Convert to linear sRGB, then gamma-correct to sRGB.
  local r = gamma(04.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s)
  local g = gamma(-1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s)
  local b = gamma(-0.0041960863 * l - 0.7034186147 * m + 1.7076147010 * s)

  -- Convert to 24-bit RGB for Nvim. Round the components.
  local r8 = math.floor(r * 0xff + 0.5)
  local g8 = math.floor(g * 0xff + 0.5)
  local b8 = math.floor(b * 0xff + 0.5)
  -- Some colours can't be represented.
  assert(
    (r8 >= 0 and r8 <= 0xff)
      and (g8 >= 0 and g8 <= 0xff)
      and (b8 >= 0 and b8 <= 0xff)
  )
  return { r8 * 0x010000 + g8 * 0x000100 + b8, approx_cterm(r8, g8, b8) }
end

local function hl(name, val)
  if type(val) == "string" then
    val = { link = val }
  else -- table
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
    vim.g["terminal_color_" .. (i - 1)] = ("#%06x"):format(color[1])
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
-- stylua: ignore
local p = setmetatable({
  bg0_float         = oklch(0.1785, 0.0160, 285.10),
  bg0               = oklch(0.2035, 0.0160, 285.10),
  bg1               = oklch(0.2285, 0.0160, 285.10),
  bg2               = oklch(0.2535, 0.0160, 285.10),
  bg3               = oklch(0.2785, 0.0160, 285.10),

  fg0               = oklch(0.8250, 0.0112,  93.58),
  fg0_moe           = oklch(0.7500, 0.0681, 129.90),
  fg0_matsu         = oklch(0.7500, 0.0588, 181.30),
  fg0_nami          = oklch(0.7500, 0.0444, 231.52),
  fg0_hasu          = oklch(0.7500, 0.0619, 332.72),
  fg1               = oklch(0.6000, 0.0061, 115.88),
  fg2               = oklch(0.5000, 0.0038, 200.63),

  red0              = oklch(0.7500, 0.1172,  24.86),
  yellow0           = oklch(0.7500, 0.0665,  86.58),
  green0            = oklch(0.7500, 0.0912, 144.55),
  cyan0             = oklch(0.7500, 0.0301, 177.27),
  blue0             = oklch(0.7500, 0.0493, 228.33),
  magenta0          = oklch(0.7500, 0.0354, 324.11),

  red1              = oklch(0.6500, 0.1172,  24.86),
  yellow1           = oklch(0.6500, 0.0665,  86.58),
  green1            = oklch(0.6500, 0.0912, 144.55),
  cyan1             = oklch(0.6500, 0.0301, 177.27),
  blue1             = oklch(0.6500, 0.0493, 228.33),
  magenta1          = oklch(0.6500, 0.0354, 324.11),

  bg_diff_add       = oklch(0.2500, 0.0456, 144.55),
  bg_diff_delete    = oklch(0.2500, 0.0586,  24.86),
  bg_diff_change    = oklch(0.2500, 0.0247, 228.33),
  bg_diff_change_em = oklch(0.3500, 0.0461, 228.33),
}, p_mt)

local base_comment = { fg = p.fg1 }
local base_string = { fg = p.fg0_moe }

-- Terminal buffers (:h terminal-config) {{{1
hl_term {
  p.bg3,
  p.red1,
  p.green1,
  p.yellow1,
  p.blue1,
  p.magenta1,
  p.cyan1,
  p.fg1,
  p.fg2,
  p.red0,
  p.green0,
  p.yellow0,
  p.blue0,
  p.magenta0,
  p.cyan0,
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
hl("Directory", { fg = p.fg0_matsu })
hl("DiffAdd", { bg = p.bg_diff_add })
hl("DiffChange", { bg = p.bg_diff_change })
hl("DiffDelete", { bg = p.bg_diff_delete })
hl("DiffText", { bg = p.bg_diff_change_em })
hl("DiffTextAdd", "DiffText")
hl("EndOfBuffer", { fg = p.fg2 })
hl("TermCursor", "Cursor")
hl("OkMsg", { fg = p.green0 })
hl("WarningMsg", { fg = p.yellow0 })
hl("ErrorMsg", { fg = p.red0 })
hl("StderrMsg", "ErrorMsg")
hl("StdoutMsg", "Normal")
hl("WinSeparator", { fg = p.bg3 })
hl("Folded", { fg = p.fg1, bg = p.bg2 })
hl("FoldColumn", { fg = p.fg1 })
hl("SignColumn", { fg = p.fg0 })
hl("IncSearch", { fg = p.bg0, bg = p.magenta1 })
hl("Substitute", "Search")
hl("LineNr", { fg = p.fg1 })
hl("LineNrAbove", "LineNr")
hl("LineNrBelow", "LineNrAbove")
hl("CursorLineNr", { fg = p.fg0, bg = p.bg1 })
hl("CursorLineFold", "FoldColumn")
hl("CursorLineSign", "SignColumn")
hl("MatchParen", { bg = p.bg3, bold = true })
hl("ModeMsg", { fg = p.fg0, bold = true })
hl("MsgArea", "Normal")
hl("MsgSeparator", "StatusLine")
hl("MoreMsg", "ModeMsg")
hl("NonText", { fg = p.fg2 })
hl("Normal", { fg = p.fg0, bg = p.bg0 })
hl("NormalFloat", { bg = p.bg0_float })
hl("FloatBorder", "NormalFloat")
hl("FloatShadow", { bg = { 0x000000, 16 }, blend = 80 })
hl("FloatShadowThrough", "FloatShadow")
hl("FloatTitle", "FloatBorder")
hl("FloatFooter", "FloatTitle")
hl("NormalNC", "Normal")
hl("Pmenu", { fg = p.fg0, bg = p.bg3 })
hl("PmenuSel", { fg = p.bg0, bg = p.fg1 })
hl("PmenuKind", { fg = p.fg1 })
hl("PmenuKindSel", "PmenuSel")
hl("PmenuExtra", { fg = p.fg2 })
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
hl("ComplHint", { fg = p.fg2 })
hl("ComplHintMore", { fg = p.fg2, bold = true })
hl("Question", "Title")
hl("QuickFixLine", { bg = p.bg2 })
hl("Search", { fg = p.bg0, bg = p.blue0 })
hl("SnippetTabstop", "Visual")
hl("SnippetTabstopActive", "SnippetTabstop")
hl("SpecialKey", "SpecialChar")
hl("SpellBad", { sp = p.red0, undercurl = true })
hl("SpellCap", { sp = p.blue0, undercurl = true })
hl("SpellLocal", { sp = p.cyan0, undercurl = true })
hl("SpellRare", { sp = p.magenta0, undercurl = true })
hl("StatusLine", { fg = p.fg0, bg = p.bg3 })
hl("StatusLineNC", { fg = p.fg1, bg = p.bg2 })
hl("StatusLineTerm", "StatusLine")
hl("StatusLineTermNC", "StatusLineNC")
hl("TabLine", "StatusLineNC")
hl("TabLineFill", "StatusLineNC")
hl("TabLineSel", "StatusLine")
hl("Title", { fg = p.fg0, bold = true })
hl("Visual", { fg = p.bg0, bg = p.fg1 })
hl("VisualNOS", "Visual")
hl("Whitespace", { fg = p.fg2 })
hl("WildMenu", "Visual")
hl("WinBar", "TabLineSel")
hl("WinBarNC", "TabLine")
hl("Menu", "Pmenu") -- Unused
hl("Scrollbar", "PmenuSbar") -- Unused
hl("Tooltip", "Pmenu") -- Unused

-- Syntax groups (:h group-name) {{{1
hl("Comment", base_comment)
hl("Constant", "Identifier")
hl("String", base_string)
hl("Character", "String")
hl("Number", { fg = p.fg0 })
hl("Boolean", "Constant")
hl("Float", "Number")
hl("Identifier", { fg = p.fg0 })
hl("Function", { fg = p.fg0_nami })
hl("Statement", "Keyword")
hl("Conditional", "Statement")
hl("Repeat", "Statement")
hl("Label", "Statement")
hl("Operator", { fg = p.fg0 })
hl("Keyword", { fg = p.fg0_hasu })
hl("Exception", "Statement")
hl("PreProc", "Keyword")
hl("Include", "PreProc")
hl("Define", "PreProc")
hl("Macro", "PreProc")
hl("PreCondit", "PreProc")
hl("Type", { fg = p.fg0_matsu })
hl("StorageClass", "Keyword")
hl("Structure", "Keyword")
hl("Typedef", "Type")
hl("Special", { fg = p.fg0 })
hl("SpecialChar", vim.tbl_extend("force", base_string, { bold = true }))
hl("Tag", "Special")
hl("Delimiter", { fg = p.fg0 })
hl("SpecialComment", vim.tbl_extend("force", base_comment, { bold = true }))
hl("Debug", "Identifier")
hl("Underlined", { underline = true })
hl("Ignore", "Comment")
hl("Error", { fg = p.red0 })
hl("Todo", "SpecialComment")
hl("Added", { fg = p.green0 })
hl("Changed", { fg = p.blue0 })
hl("Removed", { fg = p.red0 })

-- Diagnostic groups (:h diagnostic-highlights) {{{1
hl("DiagnosticError", { fg = p.red0 })
hl("DiagnosticWarn", { fg = p.yellow0 })
hl("DiagnosticInfo", { fg = p.blue0 })
hl("DiagnosticHint", { fg = p.magenta0 })
hl("DiagnosticOk", { fg = p.green0 })
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
hl("DiagnosticUnderlineError", { sp = p.red0, undercurl = true })
hl("DiagnosticUnderlineWarn", { sp = p.yellow0, undercurl = true })
hl("DiagnosticUnderlineInfo", { sp = p.blue0, undercurl = true })
hl("DiagnosticUnderlineHint", { sp = p.magenta0, undercurl = true })
hl("DiagnosticUnderlineOk", { sp = p.green0, undercurl = true })
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

-- Intention is to only highlight builtins specially; trying to highlight all is
-- too noisy and often inconsistent without semantic info from language servers.
hl("@constant", "Identifier")
hl("@constant.builtin", "Constant")
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
hl("@keyword.return", "Statement")
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

hl(
  "@comment.error",
  vim.tbl_extend("force", base_comment, { fg = p.red1, bold = true })
)
hl(
  "@comment.warning",
  vim.tbl_extend("force", base_comment, { fg = p.yellow1, bold = true })
)
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

-- comment parser {{{1
hl("@constant.comment", "@comment")
hl("@constant.comment", "@comment")
hl("@number.comment", "@comment")
hl("@punctuation.bracket.comment", "@comment")
hl("@punctuation.delimiter.comment", "@comment")

-- lua parser {{{1
hl("@constructor.lua", {})

-- LSP - semantic groups (:h lsp-semantic-highlight) {{{1
hl("@lsp.type.class", "@type")
hl("@lsp.type.comment", "@comment")
hl("@lsp.type.decorator", "@attribute")
hl("@lsp.type.enum", "@type")
hl("@lsp.type.enumMember", "@constant")
hl("@lsp.type.event", "@type")
hl("@lsp.type.function", "@function")
hl("@lsp.type.interface", "@type")
hl("@lsp.type.keyword", "@keyword")
-- Typically it's more useful to guess a more specific group based on where the
-- macro is being used. May still be useful for combined highlights, though.
hl("@lsp.type.macro", {})
hl("@lsp.type.method", "@function.method")
hl("@lsp.type.modifier", "@type.qualifier")
hl("@lsp.type.namespace", "@module")
hl("@lsp.type.number", "@number")
-- Ensures the signs of numbers still use @constant.
hl("@lsp.type.operator", {})
hl("@lsp.type.parameter", "@variable.parameter")
hl("@lsp.type.property", "@property")
hl("@lsp.type.regexp", "@string.regexp")
hl("@lsp.type.string", "@string")
hl("@lsp.type.struct", "@type")
hl("@lsp.type.type", "@type")
hl("@lsp.type.typeParameter", "@type")
hl("@lsp.type.variable", "@variable")

hl("@lsp.mod.abstract", {})
hl("@lsp.mod.async", {})
hl("@lsp.mod.declaration", {})
hl("@lsp.mod.defaultLibrary", {})
hl("@lsp.mod.definition", {})
hl("@lsp.mod.deprecated", "DiagnosticDeprecated")
hl("@lsp.mod.documentation", {})
hl("@lsp.mod.modification", {})
hl("@lsp.mod.readonly", {})
hl("@lsp.mod.static", {})

-- LSP - other groups (:h lsp-highlight) {{{1
hl("LspReferenceText", { bg = p.bg2 })
hl("LspReferenceRead", "LspReferenceText")
hl("LspReferenceWrite", "LspReferenceText")
hl("LspReferenceTarget", "LspReferenceText")
hl("LspInlayHint", "NonText")
hl("LspCodeLens", "NonText")
hl("LspCodeLensSeparator", "LspCodeLens")
hl("LspSignatureActiveParameter", "LspReferenceText")

-- $VIMRUNTIME/syntax/vim.vim {{{1
-- Mostly only overriding groups that have crap links.
hl("vimAutocmdPattern", "String")
hl("vimBracket", "SpecialChar") -- <>s in key notation.
hl("vimCommentTitle", "SpecialComment")
hl("vimEnvVar", "Identifier")
hl("vimEscape", "SpecialChar")
hl("vimFunctionMod", "Keyword")
hl("vimFunctionName", "Function")
hl("vimNotation", "SpecialChar")
hl("vimOption", "Identifier")
hl("vimUserFunc", "Function")
hl("vimWildcardStar", "SpecialChar")

-- $VIMRUNTIME/syntax/lua.vim {{{1
hl("luaFunction", "Keyword")
hl("luaTable", {}) -- Most delimiters aren't highlighted.

-- zig.vim {{{1
-- ""s in strings aren't highlighted as delimiters, so why these??
hl("zigMultilineStringDelimiter", "String")

-- copilot.vim {{{1
hl("CopilotSuggestion", "ComplHint")

-- fzf-lua {{{1
vim.g.fzf_colors = {
  ["hl"] = { "bg", "Search" },
  ["hl+"] = { "bg", "IncSearch" },
}

-- }}}1

-- vim: fdm=marker fdl=0
