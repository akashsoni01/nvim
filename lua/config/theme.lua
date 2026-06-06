local M = {}

M.mode = "coral"
M.palette = {}
M.transparent = false

---@class ThemePalette
---@field id string
---@field label string
---@field primary string
---@field primaryBright string
---@field primarySoft string
---@field primaryDark string
---@field fg string
---@field fgMuted string
---@field bg string
---@field bgAlt string
---@field bgFloat string
---@field border string
---@field cursorLine string
---@field visual string
---@field status string
---@field statusNc string
---@field tabSel string
---@field tab string
---@field pmenu string
---@field pmenuSel string
---@field lineNr string
---@field comment string
---@field string string
---@field number string
---@field constant string
---@field type string
---@field keyword string

local function set_hl(group, spec)
  vim.api.nvim_set_hl(0, group, spec)
end

local function apply_transparency(p, enabled)
  if not enabled then
    return
  end

  set_hl("Normal", { fg = p.fg, bg = "none" })
  set_hl("NormalNC", { fg = p.fgMuted, bg = "none" })
  set_hl("NormalFloat", { fg = p.fg, bg = "none" })
  set_hl("FloatBorder", { fg = p.border, bg = "none" })
  set_hl("SignColumn", { bg = "none" })
  set_hl("EndOfBuffer", { bg = "none" })
  set_hl("CursorLine", { bg = "none" })
  set_hl("StatusLine", { bg = "none", fg = p.fg, bold = true })
  set_hl("StatusLineNC", { bg = "none", fg = p.fgMuted })
  set_hl("WinBar", { bg = "none", fg = p.fg, bold = true })
  set_hl("WinBarNC", { bg = "none", fg = p.fgMuted })
end

local function apply_syntax(p)
  set_hl("Identifier", { fg = p.fg })
  set_hl("Function", { fg = p.primary, bold = true })
  set_hl("Statement", { fg = p.keyword, bold = true })
  set_hl("Keyword", { fg = p.keyword, bold = true })
  set_hl("Type", { fg = p.type, bold = true })
  set_hl("String", { fg = p.string })
  set_hl("Constant", { fg = p.constant })
  set_hl("Number", { fg = p.number })
  set_hl("Operator", { fg = p.fg })
  set_hl("Special", { fg = p.primary })
  set_hl("Comment", { fg = p.comment, italic = true })
  set_hl("@keyword", { fg = p.keyword, bold = true })
  set_hl("@type", { fg = p.type, bold = true })
  set_hl("@function", { fg = p.primary, bold = true })
  set_hl("@method", { fg = p.primary, bold = true })
  set_hl("@variable", { fg = p.fg })
  set_hl("@field", { fg = p.string })
  set_hl("@property", { fg = p.string })
  set_hl("@string", { fg = p.string })
  set_hl("@number", { fg = p.number })
  set_hl("@constant", { fg = p.constant })
  set_hl("@operator", { fg = p.fg })
  set_hl("@comment", { fg = p.comment, italic = true })
end

local function apply_palette(p, background)
  M.mode = p.id
  M.palette = p
  vim.o.background = background

  set_hl("Normal", { fg = p.fg, bg = p.bg })
  set_hl("NormalNC", { fg = p.fgMuted, bg = p.bgAlt })
  set_hl("NormalFloat", { fg = p.fg, bg = p.bgFloat })
  set_hl("FloatBorder", { fg = p.border, bg = p.bgFloat })
  set_hl("CursorLine", { bg = p.cursorLine })
  set_hl("CursorLineNr", { fg = p.primaryBright, bold = true })
  set_hl("LineNr", { fg = p.lineNr })
  set_hl("Visual", { bg = p.visual, fg = p.fg })
  set_hl("Search", { bg = p.primarySoft, fg = p.bg })
  set_hl("IncSearch", { bg = p.primary, fg = p.bgAlt, bold = true })
  set_hl("Pmenu", { bg = p.pmenu, fg = p.fg })
  set_hl("PmenuSel", { bg = p.pmenuSel, fg = p.fg, bold = true })
  set_hl("WinSeparator", { fg = p.border })
  set_hl("StatusLine", { bg = p.status, fg = p.fg, bold = true })
  set_hl("StatusLineNC", { bg = p.statusNc, fg = p.fgMuted })
  set_hl("TabLineSel", { bg = p.tabSel, fg = p.bgAlt, bold = true })
  set_hl("TabLine", { bg = p.tab, fg = p.fgMuted })
  set_hl("WinBar", { bg = p.tab, fg = p.fg, bold = true })
  set_hl("WinBarNC", { bg = p.bgAlt, fg = p.fgMuted })
  set_hl("DiagnosticError", { fg = "#ef4444" })
  set_hl("DiagnosticWarn", { fg = "#f59e0b" })
  set_hl("DiagnosticInfo", { fg = p.primaryBright })
  set_hl("DiagnosticHint", { fg = p.primarySoft })
  set_hl("DiagnosticUnderlineError", { undercurl = true, sp = "#ef4444" })
  set_hl("DiagnosticUnderlineWarn", { undercurl = true, sp = "#f59e0b" })
  set_hl("DiagnosticUnderlineInfo", { undercurl = true, sp = p.primaryBright })
  set_hl("MatchParen", { fg = p.fg, bg = p.visual, bold = true })
  set_hl("Title", { fg = p.primaryBright, bold = true })
  set_hl("Directory", { fg = p.primaryBright, bold = true })

  apply_syntax(p)
  apply_transparency(p, M.transparent)
end

local themes = {
  coral = {
    id = "coral",
    label = "Coral",
    primary = "#f97316",
    primaryBright = "#fb923c",
    primarySoft = "#fdba74",
    primaryDark = "#ea580c",
    fg = "#ffedd5",
    fgMuted = "#fed7aa",
    bg = "#100803",
    bgAlt = "#0d0603",
    bgFloat = "#1a0d07",
    border = "#9a3412",
    cursorLine = "#211108",
    visual = "#7c2d12",
    status = "#ea580c",
    statusNc = "#5a220d",
    tabSel = "#f97316",
    tab = "#241209",
    pmenu = "#241209",
    pmenuSel = "#ea580c",
    lineNr = "#9a3412",
    comment = "#c2410c",
    string = "#ffb98a",
    number = "#b45309",
    constant = "#c2410c",
    type = "#fdba74",
    keyword = "#ea580c",
  },
  light = {
    id = "light",
    label = "Light",
    primary = "#111111",
    primaryBright = "#000000",
    primarySoft = "#d9d9d9",
    primaryDark = "#111111",
    fg = "#111111",
    fgMuted = "#444444",
    bg = "#ffffff",
    bgAlt = "#f5f5f5",
    bgFloat = "#f5f5f5",
    border = "#c8c8c8",
    cursorLine = "#f0f0f0",
    visual = "#d9d9d9",
    status = "#e8e8e8",
    statusNc = "#f5f5f5",
    tabSel = "#111111",
    tab = "#f5f5f5",
    pmenu = "#f5f5f5",
    pmenuSel = "#e2e2e2",
    lineNr = "#c8c8c8",
    comment = "#444444",
    string = "#525252",
    number = "#444444",
    constant = "#444444",
    type = "#444444",
    keyword = "#111111",
  },
  yellow_dark = {
    id = "yellow_dark",
    label = "Yellow Dark",
    primary = "#facc15",
    primaryBright = "#fde047",
    primarySoft = "#fef08a",
    primaryDark = "#eab308",
    fg = "#fff9c4",
    fgMuted = "#fef08a",
    bg = "#2a2208",
    bgAlt = "#1f1806",
    bgFloat = "#332a0c",
    border = "#ca8a04",
    cursorLine = "#3d320f",
    visual = "#854d0e",
    status = "#ca8a04",
    statusNc = "#5c4308",
    tabSel = "#eab308",
    tab = "#2f260a",
    pmenu = "#2f260a",
    pmenuSel = "#a16207",
    lineNr = "#a16207",
    comment = "#d97706",
    string = "#fbbf24",
    number = "#f59e0b",
    constant = "#eab308",
    type = "#fde047",
    keyword = "#facc15",
  },
  yellow_light = {
    id = "yellow_light",
    label = "Yellow Bright",
    primary = "#a16207",
    primaryBright = "#ca8a04",
    primarySoft = "#fde047",
    primaryDark = "#92400e",
    fg = "#1c1917",
    fgMuted = "#57534e",
    bg = "#fffbeb",
    bgAlt = "#fef3c7",
    bgFloat = "#fef3c7",
    border = "#fcd34d",
    cursorLine = "#fde68a",
    visual = "#fcd34d",
    status = "#fde68a",
    statusNc = "#fef3c7",
    tabSel = "#a16207",
    tab = "#fef3c7",
    pmenu = "#fef3c7",
    pmenuSel = "#fcd34d",
    lineNr = "#fcd34d",
    comment = "#57534e",
    string = "#92400e",
    number = "#b45309",
    constant = "#a16207",
    type = "#57534e",
    keyword = "#1c1917",
  },
  ocean_dark = {
    id = "ocean_dark",
    label = "Ocean Dark",
    primary = "#2dd4bf",
    primaryBright = "#5eead4",
    primarySoft = "#99f6e4",
    primaryDark = "#14b8a6",
    fg = "#ccfbf1",
    fgMuted = "#99f6e4",
    bg = "#071318",
    bgAlt = "#051015",
    bgFloat = "#0c1f26",
    border = "#0f766e",
    cursorLine = "#0f2a33",
    visual = "#115e59",
    status = "#0f766e",
    statusNc = "#134e4a",
    tabSel = "#14b8a6",
    tab = "#0c1f26",
    pmenu = "#0c1f26",
    pmenuSel = "#0f766e",
    lineNr = "#0f766e",
    comment = "#2dd4bf",
    string = "#67e8f9",
    number = "#22d3ee",
    constant = "#06b6d4",
    type = "#5eead4",
    keyword = "#14b8a6",
  },
  ocean_light = {
    id = "ocean_light",
    label = "Ocean Bright",
    primary = "#0f766e",
    primaryBright = "#14b8a6",
    primarySoft = "#99f6e4",
    primaryDark = "#115e59",
    fg = "#0f172a",
    fgMuted = "#475569",
    bg = "#f0fdfa",
    bgAlt = "#ccfbf1",
    bgFloat = "#ccfbf1",
    border = "#5eead4",
    cursorLine = "#a7f3d0",
    visual = "#99f6e4",
    status = "#a7f3d0",
    statusNc = "#ccfbf1",
    tabSel = "#0f766e",
    tab = "#ccfbf1",
    pmenu = "#ccfbf1",
    pmenuSel = "#99f6e4",
    lineNr = "#5eead4",
    comment = "#475569",
    string = "#0e7490",
    number = "#0891b2",
    constant = "#0f766e",
    type = "#475569",
    keyword = "#0f172a",
  },
  violet_dark = {
    id = "violet_dark",
    label = "Violet Dark",
    primary = "#c084fc",
    primaryBright = "#d8b4fe",
    primarySoft = "#e9d5ff",
    primaryDark = "#a855f7",
    fg = "#f3e8ff",
    fgMuted = "#e9d5ff",
    bg = "#120818",
    bgAlt = "#0d0612",
    bgFloat = "#1a0f24",
    border = "#7e22ce",
    cursorLine = "#241433",
    visual = "#581c87",
    status = "#7e22ce",
    statusNc = "#4c1d95",
    tabSel = "#a855f7",
    tab = "#1a0f24",
    pmenu = "#1a0f24",
    pmenuSel = "#7e22ce",
    lineNr = "#7e22ce",
    comment = "#c084fc",
    string = "#f0abfc",
    number = "#e879f9",
    constant = "#d946ef",
    type = "#d8b4fe",
    keyword = "#a855f7",
  },
  violet_light = {
    id = "violet_light",
    label = "Violet Bright",
    primary = "#7e22ce",
    primaryBright = "#9333ea",
    primarySoft = "#e9d5ff",
    primaryDark = "#6b21a8",
    fg = "#1e1b4b",
    fgMuted = "#5b21b6",
    bg = "#faf5ff",
    bgAlt = "#f3e8ff",
    bgFloat = "#f3e8ff",
    border = "#d8b4fe",
    cursorLine = "#ede9fe",
    visual = "#e9d5ff",
    status = "#ede9fe",
    statusNc = "#f3e8ff",
    tabSel = "#7e22ce",
    tab = "#f3e8ff",
    pmenu = "#f3e8ff",
    pmenuSel = "#e9d5ff",
    lineNr = "#d8b4fe",
    comment = "#5b21b6",
    string = "#86198f",
    number = "#a21caf",
    constant = "#7e22ce",
    type = "#5b21b6",
    keyword = "#1e1b4b",
  },
  mint_dark = {
    id = "mint_dark",
    label = "Mint Dark",
    primary = "#34d399",
    primaryBright = "#6ee7b7",
    primarySoft = "#a7f3d0",
    primaryDark = "#10b981",
    fg = "#d1fae5",
    fgMuted = "#a7f3d0",
    bg = "#07140f",
    bgAlt = "#05100c",
    bgFloat = "#0c2219",
    border = "#047857",
    cursorLine = "#0f2f22",
    visual = "#065f46",
    status = "#047857",
    statusNc = "#064e3b",
    tabSel = "#10b981",
    tab = "#0c2219",
    pmenu = "#0c2219",
    pmenuSel = "#047857",
    lineNr = "#047857",
    comment = "#34d399",
    string = "#4ade80",
    number = "#22c55e",
    constant = "#16a34a",
    type = "#6ee7b7",
    keyword = "#10b981",
  },
  mint_light = {
    id = "mint_light",
    label = "Mint Bright",
    primary = "#047857",
    primaryBright = "#059669",
    primarySoft = "#a7f3d0",
    primaryDark = "#065f46",
    fg = "#052e16",
    fgMuted = "#166534",
    bg = "#f0fdf4",
    bgAlt = "#dcfce7",
    bgFloat = "#dcfce7",
    border = "#86efac",
    cursorLine = "#bbf7d0",
    visual = "#a7f3d0",
    status = "#bbf7d0",
    statusNc = "#dcfce7",
    tabSel = "#047857",
    tab = "#dcfce7",
    pmenu = "#dcfce7",
    pmenuSel = "#a7f3d0",
    lineNr = "#86efac",
    comment = "#166534",
    string = "#15803d",
    number = "#16a34a",
    constant = "#047857",
    type = "#166534",
    keyword = "#052e16",
  },
  rose_dark = {
    id = "rose_dark",
    label = "Rose Dark",
    primary = "#fb7185",
    primaryBright = "#fda4af",
    primarySoft = "#fecdd3",
    primaryDark = "#f43f5e",
    fg = "#ffe4e6",
    fgMuted = "#fecdd3",
    bg = "#18080d",
    bgAlt = "#12060a",
    bgFloat = "#240f16",
    border = "#be123c",
    cursorLine = "#33111c",
    visual = "#881337",
    status = "#be123c",
    statusNc = "#9f1239",
    tabSel = "#f43f5e",
    tab = "#240f16",
    pmenu = "#240f16",
    pmenuSel = "#be123c",
    lineNr = "#be123c",
    comment = "#fb7185",
    string = "#f9a8d4",
    number = "#f472b6",
    constant = "#ec4899",
    type = "#fda4af",
    keyword = "#f43f5e",
  },
  rose_light = {
    id = "rose_light",
    label = "Rose Bright",
    primary = "#be123c",
    primaryBright = "#e11d48",
    primarySoft = "#fecdd3",
    primaryDark = "#9f1239",
    fg = "#4c0519",
    fgMuted = "#9f1239",
    bg = "#fff1f2",
    bgAlt = "#ffe4e6",
    bgFloat = "#ffe4e6",
    border = "#fda4af",
    cursorLine = "#fecdd3",
    visual = "#fecdd3",
    status = "#fecdd3",
    statusNc = "#ffe4e6",
    tabSel = "#be123c",
    tab = "#ffe4e6",
    pmenu = "#ffe4e6",
    pmenuSel = "#fecdd3",
    lineNr = "#fda4af",
    comment = "#9f1239",
    string = "#be185d",
    number = "#db2777",
    constant = "#be123c",
    type = "#9f1239",
    keyword = "#4c0519",
  },
}

M.themes = themes

local cycle_order = {
  "coral",
  "light",
  "yellow_dark",
  "yellow_light",
  "ocean_dark",
  "ocean_light",
  "violet_dark",
  "violet_light",
  "mint_dark",
  "mint_light",
  "rose_dark",
  "rose_light",
}

local aliases = {
  mono = "light",
  yellow = "yellow_dark",
  yellow_bright = "yellow_light",
  ocean = "ocean_dark",
  violet = "violet_dark",
  mint = "mint_dark",
  rose = "rose_dark",
}

local function resolve_mode(mode)
  return aliases[mode] or mode
end

local function background_for(mode)
  if mode:match("_light$") or mode == "light" then
    return "light"
  end
  return "dark"
end

function M.apply(mode)
  local resolved = resolve_mode(mode)
  local palette = themes[resolved]
  if not palette then
    palette = themes.coral
    resolved = "coral"
  end

  apply_palette(palette, background_for(resolved))
  vim.cmd("redrawstatus!")
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
end

function M.toggle_yellow()
  if M.mode == "yellow_light" then
    M.apply("yellow_dark")
  elseif M.mode == "yellow_dark" then
    M.apply("yellow_light")
  else
    M.apply("yellow_dark")
  end
end

function M.cycle()
  local current = M.mode
  local next_mode = cycle_order[1]

  for index, mode in ipairs(cycle_order) do
    if mode == current then
      next_mode = cycle_order[(index % #cycle_order) + 1]
      break
    end
  end

  M.apply(next_mode)
  local palette = themes[next_mode]
  vim.notify("Theme: " .. (palette and palette.label or next_mode), vim.log.levels.INFO)
end

function M.list()
  return cycle_order
end

-- Default palette for startup consumers.
M.palette = themes.coral

return M
