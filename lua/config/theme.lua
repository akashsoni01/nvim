local M = {}

local coral = {
  primary = "#f97316",
  primaryBright = "#fb923c",
  primarySoft = "#fdba74",
  primaryDark = "#ea580c",
  surface = "#fff7ed",
  strong = "#7c2d12",
  underline = "#fb923c",
  heroEdge = "#ffedd5",
  glowPartner = "#fdba74",
  linkInsetDark = "#9a3412",
  canvasDark = "#1a0f08",
  gradientStart = "#f97316",
  gradientMid = "#fb923c",
  gradientEnd = "#ea580c",
}

local light = {
  bg = "#ffffff",
  bgAlt = "#f5f5f5",
  fg = "#111111",
  fgSoft = "#444444",
  border = "#c8c8c8",
  accent = "#000000",
}

M.mode = "coral"
M.palette = coral
M.transparent = false

local function set_hl(group, spec)
  vim.api.nvim_set_hl(0, group, spec)
end

local function apply_coral_syntax()
  set_hl("Identifier", { fg = "#ffd7b8" })
  set_hl("Function", { fg = coral.primary, bold = true })
  set_hl("Statement", { fg = coral.primaryDark, bold = true })
  set_hl("Keyword", { fg = coral.primaryDark, bold = true })
  set_hl("Type", { fg = "#fdba74", bold = true })
  set_hl("String", { fg = "#ffb98a" })
  set_hl("Constant", { fg = "#c2410c" })
  set_hl("Number", { fg = "#b45309" })
  set_hl("Operator", { fg = "#ffd7b8" })
  set_hl("Special", { fg = coral.primary })
  set_hl("@keyword", { fg = coral.primaryDark, bold = true })
  set_hl("@type", { fg = "#fdba74", bold = true })
  set_hl("@function", { fg = coral.primary, bold = true })
  set_hl("@method", { fg = coral.primary, bold = true })
  set_hl("@variable", { fg = "#ffd7b8" })
  set_hl("@field", { fg = "#ffb98a" })
  set_hl("@property", { fg = "#ffb98a" })
  set_hl("@string", { fg = "#ffb98a" })
  set_hl("@number", { fg = "#b45309" })
  set_hl("@constant", { fg = "#c2410c" })
  set_hl("@operator", { fg = "#ffd7b8" })
  set_hl("@comment", { fg = "#ea580c", italic = true })
end

local function apply_light_syntax()
  set_hl("Identifier", { fg = light.fg })
  set_hl("Function", { fg = light.accent, bold = true })
  set_hl("Statement", { fg = light.fg, bold = true })
  set_hl("Keyword", { fg = light.fg, bold = true })
  set_hl("Type", { fg = light.fgSoft, bold = true })
  set_hl("String", { fg = "#525252" })
  set_hl("Constant", { fg = light.fgSoft })
  set_hl("Number", { fg = light.fgSoft })
  set_hl("Operator", { fg = light.fg })
  set_hl("Special", { fg = light.fg })
  set_hl("@keyword", { fg = light.fg, bold = true })
  set_hl("@type", { fg = light.fgSoft, bold = true })
  set_hl("@function", { fg = light.accent, bold = true })
  set_hl("@method", { fg = light.accent, bold = true })
  set_hl("@variable", { fg = light.fg })
  set_hl("@field", { fg = light.fgSoft })
  set_hl("@property", { fg = light.fgSoft })
  set_hl("@string", { fg = light.fgSoft })
  set_hl("@number", { fg = light.fgSoft })
  set_hl("@constant", { fg = light.fgSoft })
  set_hl("@operator", { fg = light.fg })
  set_hl("@comment", { fg = light.fgSoft, italic = true })
end

local function apply_transparency(enabled)
  if enabled then
    set_hl("Normal", { bg = "none" })
    set_hl("NormalNC", { bg = "none" })
    set_hl("NormalFloat", { bg = "none" })
    set_hl("FloatBorder", { bg = "none" })
    set_hl("SignColumn", { bg = "none" })
    set_hl("EndOfBuffer", { bg = "none" })
  end
end

local function apply_coral()
  M.mode = "coral"
  M.palette = coral
  vim.o.background = "dark"

  set_hl("Normal", { fg = "#ffedd5", bg = "#100803" })
  set_hl("NormalNC", { fg = "#fed7aa", bg = "#0d0603" })
  set_hl("NormalFloat", { fg = "#ffedd5", bg = "#1a0d07" })
  set_hl("FloatBorder", { fg = "#fb923c", bg = "#1a0d07" })
  set_hl("Comment", { fg = "#c2410c", italic = true })
  set_hl("CursorLine", { bg = "#211108" })
  set_hl("CursorLineNr", { fg = coral.primaryBright, bold = true })
  set_hl("LineNr", { fg = "#9a3412" })
  set_hl("Visual", { bg = "#7c2d12", fg = "#ffedd5" })
  set_hl("Search", { bg = coral.primaryBright, fg = coral.canvasDark })
  set_hl("IncSearch", { bg = coral.primary, fg = "#fff7ed", bold = true })
  set_hl("Pmenu", { bg = "#241209", fg = "#ffedd5" })
  set_hl("PmenuSel", { bg = coral.primaryDark, fg = "#fff7ed", bold = true })
  set_hl("WinSeparator", { fg = "#9a3412" })
  set_hl("StatusLine", { bg = coral.gradientEnd, fg = "#fff7ed", bold = true })
  set_hl("StatusLineNC", { bg = "#5a220d", fg = "#fed7aa" })
  set_hl("TabLineSel", { bg = coral.primary, fg = "#fff7ed", bold = true })
  set_hl("TabLine", { bg = "#241209", fg = "#fed7aa" })
  set_hl("DiagnosticUnderlineError", { undercurl = true, sp = coral.primaryDark })
  set_hl("DiagnosticUnderlineWarn", { undercurl = true, sp = coral.primaryBright })
  set_hl("DiagnosticUnderlineInfo", { undercurl = true, sp = coral.primarySoft })
  set_hl("WinBar", { bg = coral.heroEdge, fg = coral.strong, bold = true })
  set_hl("WinBarNC", { bg = coral.surface, fg = coral.linkInsetDark })
  set_hl("DiagnosticError", { fg = "#b91c1c" })
  set_hl("DiagnosticWarn", { fg = "#b45309" })
  set_hl("DiagnosticInfo", { fg = coral.primaryBright })
  set_hl("DiagnosticHint", { fg = "#fb923c" })
  set_hl("MatchParen", { fg = "#fff7ed", bg = "#7c2d12", bold = true })
  set_hl("Title", { fg = coral.primaryBright, bold = true })
  set_hl("Directory", { fg = coral.primaryBright, bold = true })
  set_hl("WinBar", { bg = "#241209", fg = "#ffedd5", bold = true })
  set_hl("WinBarNC", { bg = "#140a05", fg = "#fed7aa" })
  apply_coral_syntax()

  apply_transparency(M.transparent)
end

local function apply_light()
  M.mode = "light"
  M.palette = light
  vim.o.background = "light"

  set_hl("Normal", { fg = light.fg, bg = light.bg })
  set_hl("NormalFloat", { fg = light.fg, bg = light.bgAlt })
  set_hl("FloatBorder", { fg = light.border, bg = light.bgAlt })
  set_hl("Comment", { fg = light.fgSoft, italic = true })
  set_hl("CursorLine", { bg = "#f0f0f0" })
  set_hl("CursorLineNr", { fg = light.accent, bold = true })
  set_hl("LineNr", { fg = light.border })
  set_hl("Visual", { bg = "#d9d9d9", fg = light.fg })
  set_hl("Search", { bg = "#ffe6b0", fg = light.fg })
  set_hl("IncSearch", { bg = "#ffd27a", fg = "#000000", bold = true })
  set_hl("Pmenu", { bg = light.bgAlt, fg = light.fg })
  set_hl("PmenuSel", { bg = "#e2e2e2", fg = light.fg, bold = true })
  set_hl("WinSeparator", { fg = light.border })
  set_hl("StatusLine", { bg = "#e8e8e8", fg = light.fg, bold = true })
  set_hl("StatusLineNC", { bg = light.bgAlt, fg = light.fgSoft })
  set_hl("TabLineSel", { bg = light.fg, fg = light.bg, bold = true })
  set_hl("TabLine", { bg = light.bgAlt, fg = light.fgSoft })
  set_hl("WinBar", { bg = light.bgAlt, fg = light.fg, bold = true })
  set_hl("WinBarNC", { bg = light.bg, fg = light.fgSoft })
  set_hl("DiagnosticError", { fg = "#ff7b7b" })
  set_hl("DiagnosticWarn", { fg = "#b45309" })
  set_hl("DiagnosticInfo", { fg = light.fg })
  set_hl("DiagnosticHint", { fg = light.fgSoft })
  set_hl("MatchParen", { fg = light.fg, bg = "#d0d0d0", bold = true })
  set_hl("Title", { fg = light.fg, bold = true })
  set_hl("Directory", { fg = light.fg, bold = true })
  apply_light_syntax()
end

function M.apply(mode)
  if mode == "light" or mode == "mono" then
    apply_light()
  else
    apply_coral()
  end
end

function M.toggle_transparency()
  M.transparent = not M.transparent
  M.apply(M.mode)
end

function M.toggle()
  if M.mode == "coral" then
    M.apply("light")
  else
    M.apply("coral")
  end
  vim.cmd "redrawstatus!"
end

return M
