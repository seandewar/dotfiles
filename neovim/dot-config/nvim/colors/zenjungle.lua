-- Slim, low-distraction colour scheme inspired by zenwritten and evergarden.
-- https://github.com/zenbones-theme/zenbones.nvim
-- https://github.com/everviolet/nvim

local api = vim.api

vim.cmd.highlight "clear"
vim.o.background = "dark"
vim.g.colors_name = "zenjungle"

-- Helpers {{{1
local approx_cterm
do
  local cterm_lut = {
    -- System colours (cterm 0-15)
    { 0, 0, 0 },
    { 128, 0, 0 },
    { 0, 128, 0 },
    { 128, 128, 0 },
    { 0, 0, 128 },
    { 128, 0, 128 },
    { 0, 128, 128 },
    { 192, 192, 192 },
    { 128, 128, 128 },
    { 255, 0, 0 },
    { 0, 255, 0 },
    { 255, 255, 0 },
    { 0, 0, 255 },
    { 255, 0, 255 },
    { 0, 255, 255 },
    { 255, 255, 255 },
  }

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
  assert(#cterm_lut == 256)

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
    return best_lut_i - 1
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
-- stylua: ignore
local p = setmetatable({
  bg0_float         =   oklch(0.175, 0.014, 176.96),
  bg0               =   oklch(0.190, 0.017, 176.96),
  bg1               =   oklch(0.220, 0.020, 176.96),
  bg2               =   oklch(0.250, 0.023, 176.96),
  bg3               =   oklch(0.280, 0.026, 176.96),

  fg0               =   oklch(0.800, 0.040, 176.96),
  fg1               =   oklch(0.660, 0.038, 176.96),
  fg2               =   oklch(0.520, 0.036, 176.96),
  fg3               =   oklch(0.380, 0.034, 176.96),

  red               =   oklch(0.725, 0.075,  25.00),
  green             =   oklch(0.725, 0.080, 140.00),
  yellow            =   oklch(0.725, 0.060, 105.00),
  blue              =   oklch(0.725, 0.070, 240.00),
  magenta           =   oklch(0.725, 0.055, 330.00),
  cyan              =   oklch(0.725, 0.065, 195.00),

  br_red            =   oklch(0.750, 0.075,  25.00),
  br_green          =   oklch(0.750, 0.080, 140.00),
  br_yellow         =   oklch(0.750, 0.060, 105.00),
  br_blue           =   oklch(0.750, 0.070, 240.00),
  br_magenta        =   oklch(0.750, 0.055, 330.00),
  br_cyan           =   oklch(0.750, 0.065, 195.00),

  bg_diff_add       =   oklch(0.280, 0.050, 142.00),
  bg_diff_delete    =   oklch(0.280, 0.050,  25.00),
  bg_diff_change    =   oklch(0.280, 0.050, 240.00),
  bg_diff_change_em =   oklch(0.390, 0.060, 195.00),

  pure_black        = { 0x000000, 16  },
}, p_mt)

p.fg0_alt1 = p.yellow
p.fg0_alt2 = p.magenta
p.fg0_alt3 = p.green
p.fg0_alt4 = p.cyan
p.fg0_alt5 = p.blue

p.fg_comment = p.fg2
p.fg_delim = p.fg1
p.fg_fn = p.fg0_alt3
p.fg_kw = p.fg0_alt5
p.fg_number = p.fg0_alt2
p.fg_oper = p.fg0
p.fg_string = p.fg0_alt1
p.fg_type = p.fg0_alt4

-- Terminal buffers (:h terminal-config) {{{1
hl_term {
  p.bg2,
  p.red,
  p.green,
  p.yellow,
  p.blue,
  p.magenta,
  p.cyan,
  p.fg2,
  p.fg3,
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
hl("Directory", { fg = p.magenta })
hl("DiffAdd", { bg = p.bg_diff_add })
hl("DiffChange", { bg = p.bg_diff_change })
hl("DiffDelete", { bg = p.bg_diff_delete })
hl("DiffText", { bg = p.bg_diff_change_em })
hl("DiffTextAdd", "DiffText")
hl("EndOfBuffer", { fg = p.fg3 })
hl("TermCursor", "Cursor")
hl("OkMsg", { fg = p.green })
hl("WarningMsg", { fg = p.br_yellow })
hl("ErrorMsg", { fg = p.br_red })
hl("StderrMsg", "ErrorMsg")
hl("StdoutMsg", "Normal")
hl("WinSeparator", { fg = p.bg3 })
hl("Folded", { fg = p.fg2, bg = p.bg2 })
hl("FoldColumn", { fg = p.fg3 })
hl("SignColumn", { fg = p.fg0 })
hl("IncSearch", { fg = p.bg0, bg = p.magenta })
hl("Substitute", "Search")
hl("LineNr", { fg = p.fg3 })
hl("LineNrAbove", "LineNr")
hl("LineNrBelow", "LineNrAbove")
hl("CursorLineNr", { fg = p.fg0, bg = p.bg1 })
hl("CursorLineFold", "FoldColumn")
hl("CursorLineSign", "SignColumn")
hl("MatchParen", { fg = p.magenta, bold = true })
hl("ModeMsg", { fg = p.fg0, bold = true })
hl("MsgArea", "Normal")
hl("MsgSeparator", "StatusLine")
hl("MoreMsg", "ModeMsg")
hl("NonText", { fg = p.fg3 })
hl("Normal", { fg = p.fg0, bg = p.bg0 })
hl("NormalFloat", { bg = p.bg0_float })
hl("FloatBorder", "NormalFloat")
hl("FloatShadow", { bg = p.pure_black, blend = 80 })
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
hl("Search", { fg = p.bg0, bg = p.yellow })
hl("SnippetTabstop", "Visual")
hl("SnippetTabstopActive", "SnippetTabstop")
hl("SpecialKey", "SpecialChar")
hl("SpellBad", { sp = p.br_red, undercurl = true })
hl("SpellCap", { sp = p.br_blue, undercurl = true })
hl("SpellLocal", { sp = p.br_cyan, undercurl = true })
hl("SpellRare", { sp = p.br_magenta, undercurl = true })
hl("StatusLine", { fg = p.fg0, bg = p.bg3 })
hl("StatusLineNC", { fg = p.fg2, bg = p.bg2 })
hl("StatusLineTerm", "StatusLine")
hl("StatusLineTermNC", "StatusLineNC")
hl("TabLine", "StatusLineNC")
hl("TabLineFill", "StatusLineNC")
hl("TabLineSel", "StatusLine")
hl("Title", { fg = p.fg0, bold = true })
hl("Visual", { fg = p.bg0, bg = p.fg1 })
hl("VisualNOS", "Visual")
hl("Whitespace", { fg = p.fg3 })
hl("WildMenu", "Visual")
hl("WinBar", "TabLineSel")
hl("WinBarNC", "TabLine")
-- hl("Menu", "Pmenu") -- Unused
-- hl("Scrollbar", "PmenuSbar") -- Unused
-- hl("Tooltip", "Pmenu") -- Unused

-- Syntax groups (:h group-name) {{{1
hl("Comment", { fg = p.fg_comment })
hl("Constant", "Identifier")
hl("String", { fg = p.fg_string })
hl("Character", "String")
hl("Number", { fg = p.fg_number })
hl("Boolean", "Constant")
hl("Float", "Number")
hl("Identifier", { fg = p.fg0 })
hl("Function", { fg = p.fg_fn })
hl("Statement", "Keyword")
hl("Conditional", "Keyword")
hl("Repeat", "Keyword")
hl("Label", "Keyword")
hl("Operator", { fg = p.fg_oper })
hl("Keyword", { fg = p.fg_kw })
hl("Exception", "Keyword")
hl("PreProc", "Keyword")
hl("Include", "PreProc")
hl("Define", "PreProc")
hl("Macro", "PreProc")
hl("PreCondit", "PreProc")
hl("Type", { fg = p.fg_type })
hl("StorageClass", "Keyword")
hl("Structure", "Keyword")
hl("Typedef", "Type")
hl("Special", { fg = p.fg0 })
hl("SpecialChar", { fg = p.fg_string, bold = true })
hl("Tag", "Special")
hl("Delimiter", { fg = p.fg_delim })
hl("SpecialComment", { fg = p.fg_comment, bold = true })
hl("Debug", "Identifier")
hl("Underlined", { underline = true })
hl("Ignore", "Comment")
hl("Error", { fg = p.red })
hl("Todo", "SpecialComment")
hl("Added", { fg = p.green })
hl("Changed", { fg = p.blue })
hl("Removed", { fg = p.red })

-- Diagnostic groups (:h diagnostic-highlights) {{{1
hl("DiagnosticError", { fg = p.br_red })
hl("DiagnosticWarn", { fg = p.br_yellow })
hl("DiagnosticInfo", { fg = p.br_blue })
hl("DiagnosticHint", { fg = p.br_magenta })
hl("DiagnosticOk", { fg = p.br_green })
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
hl("DiagnosticUnderlineError", { sp = p.br_red, undercurl = true })
hl("DiagnosticUnderlineWarn", { sp = p.br_yellow, undercurl = true })
hl("DiagnosticUnderlineInfo", { sp = p.br_blue, undercurl = true })
hl("DiagnosticUnderlineHint", { sp = p.br_magenta, undercurl = true })
hl("DiagnosticUnderlineOk", { sp = p.br_green, undercurl = true })
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

hl("@comment.error", { fg = p.br_red, bold = true })
hl("@comment.warning", { fg = p.br_yellow, bold = true })
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
hl("LspCodeLens", { fg = p.fg2 })
hl("LspCodeLensSeparator", "LspCodeLens")
hl("LspSignatureActiveParameter", "LspReferenceText")

-- syntax/vim.vim overrides {{{1
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

-- syntax/lua.vim overrides {{{1
hl("luaFunction", "Keyword")
hl("luaTable", {}) -- Most delimiters aren't highlighted.

-- copilot.vim {{{1
hl("CopilotSuggestion", "ComplHint")

-- fzf-lua {{{1
vim.g.fzf_colors = {
  ["hl"] = { "bg", "Search" },
  ["hl+"] = { "bg", "IncSearch" },
}

-- }}}1
-- vim: fdm=marker
