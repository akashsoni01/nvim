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

local mono = {
  bg = "#000000",
  bgAlt = "#111111",
  fg = "#ffffff",
  fgSoft = "#d4d4d4",
  border = "#7a7a7a",
  accent = "#f5f5f5",
}

M.mode = "coral"
M.palette = coral
M.transparent = false

local function set_hl(group, spec)
  vim.api.nvim_set_hl(0, group, spec)
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
  vim.o.background = "light"

  set_hl("Normal", { fg = coral.strong, bg = coral.surface })
  set_hl("NormalFloat", { fg = coral.strong, bg = coral.heroEdge })
  set_hl("FloatBorder", { fg = coral.primaryBright, bg = coral.heroEdge })
  set_hl("Comment", { fg = coral.linkInsetDark, italic = true })
  set_hl("CursorLine", { bg = coral.heroEdge })
  set_hl("CursorLineNr", { fg = coral.primaryDark, bold = true })
  set_hl("LineNr", { fg = coral.primarySoft })
  set_hl("Visual", { bg = coral.primarySoft, fg = coral.canvasDark })
  set_hl("Search", { bg = coral.primaryBright, fg = coral.canvasDark })
  set_hl("IncSearch", { bg = coral.primaryDark, fg = coral.surface })
  set_hl("Pmenu", { bg = coral.heroEdge, fg = coral.strong })
  set_hl("PmenuSel", { bg = coral.primarySoft, fg = coral.canvasDark, bold = true })
  set_hl("WinSeparator", { fg = coral.primarySoft })
  set_hl("StatusLine", { bg = coral.gradientEnd, fg = coral.surface, bold = true })
  set_hl("StatusLineNC", { bg = coral.primarySoft, fg = coral.linkInsetDark })
  set_hl("TabLineSel", { bg = coral.primary, fg = coral.surface, bold = true })
  set_hl("DiagnosticUnderlineError", { undercurl = true, sp = coral.primaryDark })
  set_hl("DiagnosticUnderlineWarn", { undercurl = true, sp = coral.primaryBright })
  set_hl("DiagnosticUnderlineInfo", { undercurl = true, sp = coral.primarySoft })
  set_hl("WinBar", { bg = coral.heroEdge, fg = coral.strong, bold = true })
  set_hl("WinBarNC", { bg = coral.surface, fg = coral.linkInsetDark })

  apply_transparency(M.transparent)
end

local function apply_mono()
  M.mode = "mono"
  M.palette = mono
  vim.o.background = "dark"

  set_hl("Normal", { fg = mono.fg, bg = mono.bg })
  set_hl("NormalFloat", { fg = mono.fg, bg = mono.bgAlt })
  set_hl("FloatBorder", { fg = mono.border, bg = mono.bgAlt })
  set_hl("Comment", { fg = mono.fgSoft, italic = true })
  set_hl("CursorLine", { bg = mono.bgAlt })
  set_hl("CursorLineNr", { fg = mono.accent, bold = true })
  set_hl("LineNr", { fg = mono.border })
  set_hl("Visual", { bg = "#2f2f2f", fg = mono.fg })
  set_hl("Search", { bg = "#5f5f5f", fg = mono.fg })
  set_hl("IncSearch", { bg = mono.fg, fg = mono.bg })
  set_hl("Pmenu", { bg = mono.bgAlt, fg = mono.fg })
  set_hl("PmenuSel", { bg = "#404040", fg = mono.fg, bold = true })
  set_hl("WinSeparator", { fg = mono.border })
  set_hl("StatusLine", { bg = "#2a2a2a", fg = mono.fg, bold = true })
  set_hl("StatusLineNC", { bg = mono.bgAlt, fg = mono.fgSoft })
  set_hl("TabLineSel", { bg = mono.fg, fg = mono.bg, bold = true })
  set_hl("WinBar", { bg = mono.bgAlt, fg = mono.fg, bold = true })
  set_hl("WinBarNC", { bg = mono.bg, fg = mono.fgSoft })
end

function M.apply(mode)
  if mode == "mono" then
    apply_mono()
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
    M.apply("mono")
  else
    M.apply("coral")
  end
  vim.cmd "redrawstatus!"
end

return M
