local M = {}

M.mode = "coral"
M.default_mode = "coral"
M.palette = {}
M.transparent = false

local function default_mode_path()
  return vim.fn.stdpath("data") .. "/nvim-theme-default.json"
end

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
  slate_dark = {
    id = "slate_dark",
    label = "Slate Dark",
    primary = "#94a3b8",
    primaryBright = "#cbd5e1",
    primarySoft = "#e2e8f0",
    primaryDark = "#64748b",
    fg = "#e2e8f0",
    fgMuted = "#94a3b8",
    bg = "#0b1120",
    bgAlt = "#080d18",
    bgFloat = "#111827",
    border = "#475569",
    cursorLine = "#1e293b",
    visual = "#334155",
    status = "#334155",
    statusNc = "#1e293b",
    tabSel = "#64748b",
    tab = "#111827",
    pmenu = "#111827",
    pmenuSel = "#334155",
    lineNr = "#475569",
    comment = "#64748b",
    string = "#7dd3fc",
    number = "#38bdf8",
    constant = "#60a5fa",
    type = "#cbd5e1",
    keyword = "#94a3b8",
  },
  slate_light = {
    id = "slate_light",
    label = "Slate Bright",
    primary = "#334155",
    primaryBright = "#475569",
    primarySoft = "#cbd5e1",
    primaryDark = "#1e293b",
    fg = "#0f172a",
    fgMuted = "#475569",
    bg = "#f8fafc",
    bgAlt = "#f1f5f9",
    bgFloat = "#f1f5f9",
    border = "#cbd5e1",
    cursorLine = "#e2e8f0",
    visual = "#cbd5e1",
    status = "#e2e8f0",
    statusNc = "#f1f5f9",
    tabSel = "#334155",
    tab = "#f1f5f9",
    pmenu = "#f1f5f9",
    pmenuSel = "#cbd5e1",
    lineNr = "#cbd5e1",
    comment = "#64748b",
    string = "#0369a1",
    number = "#0284c7",
    constant = "#334155",
    type = "#475569",
    keyword = "#0f172a",
  },
  amber_dark = {
    id = "amber_dark",
    label = "Amber Dark",
    primary = "#f59e0b",
    primaryBright = "#fbbf24",
    primarySoft = "#fcd34d",
    primaryDark = "#d97706",
    fg = "#fef3c7",
    fgMuted = "#fde68a",
    bg = "#1c1208",
    bgAlt = "#140d06",
    bgFloat = "#261a0c",
    border = "#b45309",
    cursorLine = "#302010",
    visual = "#78350f",
    status = "#b45309",
    statusNc = "#713f12",
    tabSel = "#d97706",
    tab = "#261a0c",
    pmenu = "#261a0c",
    pmenuSel = "#92400e",
    lineNr = "#92400e",
    comment = "#d97706",
    string = "#fb923c",
    number = "#f59e0b",
    constant = "#ea580c",
    type = "#fcd34d",
    keyword = "#fbbf24",
  },
  amber_light = {
    id = "amber_light",
    label = "Amber Bright",
    primary = "#b45309",
    primaryBright = "#d97706",
    primarySoft = "#fde68a",
    primaryDark = "#92400e",
    fg = "#292524",
    fgMuted = "#78716c",
    bg = "#fffaf0",
    bgAlt = "#ffedd5",
    bgFloat = "#ffedd5",
    border = "#fdba74",
    cursorLine = "#fed7aa",
    visual = "#fdba74",
    status = "#fed7aa",
    statusNc = "#ffedd5",
    tabSel = "#b45309",
    tab = "#ffedd5",
    pmenu = "#ffedd5",
    pmenuSel = "#fdba74",
    lineNr = "#fdba74",
    comment = "#78716c",
    string = "#c2410c",
    number = "#ea580c",
    constant = "#b45309",
    type = "#78716c",
    keyword = "#292524",
  },
  cherry_dark = {
    id = "cherry_dark",
    label = "Cherry Dark",
    primary = "#ef4444",
    primaryBright = "#f87171",
    primarySoft = "#fca5a5",
    primaryDark = "#dc2626",
    fg = "#fee2e2",
    fgMuted = "#fca5a5",
    bg = "#160808",
    bgAlt = "#100505",
    bgFloat = "#220c0c",
    border = "#991b1b",
    cursorLine = "#2d1010",
    visual = "#7f1d1d",
    status = "#991b1b",
    statusNc = "#7f1d1d",
    tabSel = "#dc2626",
    tab = "#220c0c",
    pmenu = "#220c0c",
    pmenuSel = "#991b1b",
    lineNr = "#991b1b",
    comment = "#f87171",
    string = "#fb7185",
    number = "#ef4444",
    constant = "#dc2626",
    type = "#fca5a5",
    keyword = "#f87171",
  },
  cherry_light = {
    id = "cherry_light",
    label = "Cherry Bright",
    primary = "#b91c1c",
    primaryBright = "#dc2626",
    primarySoft = "#fca5a5",
    primaryDark = "#991b1b",
    fg = "#450a0a",
    fgMuted = "#7f1d1d",
    bg = "#fef2f2",
    bgAlt = "#fee2e2",
    bgFloat = "#fee2e2",
    border = "#fca5a5",
    cursorLine = "#fecaca",
    visual = "#fca5a5",
    status = "#fecaca",
    statusNc = "#fee2e2",
    tabSel = "#b91c1c",
    tab = "#fee2e2",
    pmenu = "#fee2e2",
    pmenuSel = "#fca5a5",
    lineNr = "#fca5a5",
    comment = "#7f1d1d",
    string = "#be123c",
    number = "#dc2626",
    constant = "#b91c1c",
    type = "#7f1d1d",
    keyword = "#450a0a",
  },
  arctic_dark = {
    id = "arctic_dark",
    label = "Arctic Dark",
    primary = "#60a5fa",
    primaryBright = "#93c5fd",
    primarySoft = "#bfdbfe",
    primaryDark = "#3b82f6",
    fg = "#dbeafe",
    fgMuted = "#bfdbfe",
    bg = "#060d18",
    bgAlt = "#040a12",
    bgFloat = "#0c1828",
    border = "#1d4ed8",
    cursorLine = "#0f1f38",
    visual = "#1e3a8a",
    status = "#1d4ed8",
    statusNc = "#1e3a8a",
    tabSel = "#3b82f6",
    tab = "#0c1828",
    pmenu = "#0c1828",
    pmenuSel = "#1d4ed8",
    lineNr = "#1d4ed8",
    comment = "#60a5fa",
    string = "#7dd3fc",
    number = "#38bdf8",
    constant = "#2563eb",
    type = "#93c5fd",
    keyword = "#3b82f6",
  },
  arctic_light = {
    id = "arctic_light",
    label = "Arctic Bright",
    primary = "#1d4ed8",
    primaryBright = "#2563eb",
    primarySoft = "#bfdbfe",
    primaryDark = "#1e40af",
    fg = "#0c1a3a",
    fgMuted = "#1e3a8a",
    bg = "#f0f7ff",
    bgAlt = "#dbeafe",
    bgFloat = "#dbeafe",
    border = "#93c5fd",
    cursorLine = "#bfdbfe",
    visual = "#bfdbfe",
    status = "#bfdbfe",
    statusNc = "#dbeafe",
    tabSel = "#1d4ed8",
    tab = "#dbeafe",
    pmenu = "#dbeafe",
    pmenuSel = "#bfdbfe",
    lineNr = "#93c5fd",
    comment = "#1e3a8a",
    string = "#0369a1",
    number = "#0284c7",
    constant = "#1d4ed8",
    type = "#1e3a8a",
    keyword = "#0c1a3a",
  },
  forest_dark = {
    id = "forest_dark",
    label = "Forest Dark",
    primary = "#4ade80",
    primaryBright = "#86efac",
    primarySoft = "#bbf7d0",
    primaryDark = "#22c55e",
    fg = "#dcfce7",
    fgMuted = "#bbf7d0",
    bg = "#061208",
    bgAlt = "#040d06",
    bgFloat = "#0c1a10",
    border = "#166534",
    cursorLine = "#0f2418",
    visual = "#14532d",
    status = "#166534",
    statusNc = "#14532d",
    tabSel = "#22c55e",
    tab = "#0c1a10",
    pmenu = "#0c1a10",
    pmenuSel = "#166534",
    lineNr = "#166534",
    comment = "#4ade80",
    string = "#6ee7b7",
    number = "#34d399",
    constant = "#16a34a",
    type = "#86efac",
    keyword = "#22c55e",
  },
  forest_light = {
    id = "forest_light",
    label = "Forest Bright",
    primary = "#166534",
    primaryBright = "#15803d",
    primarySoft = "#bbf7d0",
    primaryDark = "#14532d",
    fg = "#052e16",
    fgMuted = "#166534",
    bg = "#f4faf6",
    bgAlt = "#e8f5ec",
    bgFloat = "#e8f5ec",
    border = "#86efac",
    cursorLine = "#d1fae5",
    visual = "#bbf7d0",
    status = "#d1fae5",
    statusNc = "#e8f5ec",
    tabSel = "#166534",
    tab = "#e8f5ec",
    pmenu = "#e8f5ec",
    pmenuSel = "#bbf7d0",
    lineNr = "#86efac",
    comment = "#166534",
    string = "#15803d",
    number = "#16a34a",
    constant = "#166534",
    type = "#166534",
    keyword = "#052e16",
  },
  dracula_dark = {
    id = "dracula_dark",
    label = "Dracula Dark",
    primary = "#bd93f9",
    primaryBright = "#ff79c6",
    primarySoft = "#8be9fd",
    primaryDark = "#6272a4",
    fg = "#f8f8f2",
    fgMuted = "#bfbfb5",
    bg = "#282a36",
    bgAlt = "#21222c",
    bgFloat = "#343746",
    border = "#6272a4",
    cursorLine = "#313341",
    visual = "#44475a",
    status = "#44475a",
    statusNc = "#343746",
    tabSel = "#bd93f9",
    tab = "#343746",
    pmenu = "#343746",
    pmenuSel = "#44475a",
    lineNr = "#6272a4",
    comment = "#6272a4",
    string = "#f1fa8c",
    number = "#bd93f9",
    constant = "#ffb86c",
    type = "#8be9fd",
    keyword = "#ff79c6",
  },
  dracula_light = {
    id = "dracula_light",
    label = "Dracula Light",
    primary = "#7c6fae",
    primaryBright = "#d56baa",
    primarySoft = "#3aa7c8",
    primaryDark = "#5b6b8a",
    fg = "#282a36",
    fgMuted = "#5b6078",
    bg = "#f8f8f2",
    bgAlt = "#eff0eb",
    bgFloat = "#eff0eb",
    border = "#c4c5c9",
    cursorLine = "#e4e5e0",
    visual = "#d8d9d4",
    status = "#e4e5e0",
    statusNc = "#eff0eb",
    tabSel = "#7c6fae",
    tab = "#eff0eb",
    pmenu = "#eff0eb",
    pmenuSel = "#d8d9d4",
    lineNr = "#9aa0b4",
    comment = "#5b6b8a",
    string = "#8a7f2e",
    number = "#7c6fae",
    constant = "#b8742f",
    type = "#2f8fad",
    keyword = "#c24f93",
  },
  solarized_dark = {
    id = "solarized_dark",
    label = "Solarized Dark",
    primary = "#268bd2",
    primaryBright = "#2aa198",
    primarySoft = "#93a2a1",
    primaryDark = "#586e75",
    fg = "#839496",
    fgMuted = "#657b83",
    bg = "#002b36",
    bgAlt = "#00252f",
    bgFloat = "#073642",
    border = "#586e75",
    cursorLine = "#073642",
    visual = "#073642",
    status = "#073642",
    statusNc = "#002b36",
    tabSel = "#268bd2",
    tab = "#073642",
    pmenu = "#073642",
    pmenuSel = "#586e75",
    lineNr = "#586e75",
    comment = "#586e75",
    string = "#2aa198",
    number = "#d33682",
    constant = "#cb4b16",
    type = "#b58900",
    keyword = "#859900",
  },
  solarized_light = {
    id = "solarized_light",
    label = "Solarized Light",
    primary = "#268bd2",
    primaryBright = "#2aa198",
    primarySoft = "#93a2a1",
    primaryDark = "#657b83",
    fg = "#657b83",
    fgMuted = "#839496",
    bg = "#fdf6e3",
    bgAlt = "#eee8d5",
    bgFloat = "#eee8d5",
    border = "#93a2a1",
    cursorLine = "#eee8d5",
    visual = "#e3dcc8",
    status = "#eee8d5",
    statusNc = "#fdf6e3",
    tabSel = "#268bd2",
    tab = "#eee8d5",
    pmenu = "#eee8d5",
    pmenuSel = "#e3dcc8",
    lineNr = "#93a2a1",
    comment = "#93a2a1",
    string = "#2aa198",
    number = "#d33682",
    constant = "#cb4b16",
    type = "#b58900",
    keyword = "#859900",
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
  "slate_dark",
  "slate_light",
  "amber_dark",
  "amber_light",
  "cherry_dark",
  "cherry_light",
  "arctic_dark",
  "arctic_light",
  "forest_dark",
  "forest_light",
  "dracula_dark",
  "dracula_light",
  "solarized_dark",
  "solarized_light",
}

local aliases = {
  mono = "light",
  yellow = "yellow_dark",
  yellow_bright = "yellow_light",
  ocean = "ocean_dark",
  violet = "violet_dark",
  mint = "mint_dark",
  rose = "rose_dark",
  slate = "slate_dark",
  amber = "amber_dark",
  cherry = "cherry_dark",
  arctic = "arctic_dark",
  forest = "forest_dark",
  dracula = "dracula_dark",
  drequla = "dracula_dark",
  solarized = "solarized_dark",
  solorized = "solarized_dark",
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

function M.load_default()
  local path = default_mode_path()
  if not vim.uv.fs_stat(path) then
    return M.default_mode
  end

  local ok, decoded = pcall(vim.json.decode, table.concat(vim.fn.readfile(path), "\n"))
  if not ok or type(decoded) ~= "table" or type(decoded.mode) ~= "string" then
    return M.default_mode
  end

  local resolved = resolve_mode(decoded.mode)
  if not themes[resolved] then
    return M.default_mode
  end

  M.default_mode = resolved
  return resolved
end

function M.save_default(mode)
  local resolved = resolve_mode(mode)
  if not themes[resolved] then
    return false
  end

  M.default_mode = resolved
  local path = default_mode_path()
  vim.fn.mkdir(vim.fs.dirname(path), "p")

  local payload = vim.json.encode({ mode = resolved })
  local fd = vim.uv.fs_open(path, "w", 420)
  if not fd then
    return false
  end

  vim.uv.fs_write(fd, payload)
  vim.uv.fs_close(fd)
  return true
end

function M.set_default(mode)
  M.save_default(mode)
  M.apply(mode)
end

function M.apply_default()
  M.apply(M.load_default())
end

function M.toggle_transparency()
  M.transparent = not M.transparent
  M.apply(M.mode)
end

function M.list()
  return cycle_order
end

function M.setup()
  vim.api.nvim_create_user_command("Theme", function()
    M.pick()
  end, { desc = "Select theme with Telescope" })
end

local function ensure_telescope()
  local ok_lazy, lazy = pcall(require, "lazy")
  if ok_lazy then
    lazy.load({ plugins = { "telescope.nvim" } })
  end

  local ok, _ = pcall(require, "telescope.pickers")
  if not ok then
    vim.notify("Telescope is not available. Run :Telescope or vendor plugins first.", vim.log.levels.ERROR)
    return false
  end

  return true
end

function M.pick()
  if not ensure_telescope() then
    return
  end

  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  local previewers = require("telescope.previewers")

  pickers
    .new({}, {
      prompt_title = "Select Theme",
      layout_strategy = "vertical",
      layout_config = {
        height = 0.55,
        prompt_position = "top",
        preview_cutoff = 20,
      },
      finder = finders.new_table({
        results = cycle_order,
        entry_maker = function(mode)
          local palette = themes[mode]
          local marker = mode == M.mode and "● " or "  "
          local variant = background_for(mode) == "light" and "bright" or "dark"
          return {
            value = mode,
            display = string.format("%s%s (%s)", marker, palette.label, variant),
            ordinal = palette.label .. " " .. mode .. " " .. variant,
            palette = palette,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      previewer = previewers.new_buffer_previewer({
        title = "Theme preview",
        define_preview = function(self, entry)
          local palette = entry.palette
          local lines = {
            palette.label,
            "",
            "Mode:      " .. entry.value,
            "Variant:   " .. (background_for(entry.value) == "light" and "bright" or "dark"),
            "Background " .. palette.bg,
            "Foreground " .. palette.fg,
            "Primary    " .. palette.primary,
            "Accent     " .. palette.primaryBright,
          }
          if entry.value == M.mode then
            lines[#lines + 1] = ""
            lines[#lines + 1] = "Currently active"
          end
          vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
          vim.bo[self.state.bufnr].filetype = "markdown"
        end,
      }),
      attach_mappings = function(prompt_bufnr)
        local saved_mode = M.mode
        local confirmed = false

        local function preview_selection()
          local entry = action_state.get_selected_entry()
          if entry then
            M.apply(entry.value)
          end
        end

        local function preview_on_move(action)
          action:enhance({
            post = function()
              preview_selection()
            end,
          })
        end

        preview_on_move(actions.move_selection_next)
        preview_on_move(actions.move_selection_previous)
        preview_on_move(actions.move_selection_better)
        preview_on_move(actions.move_selection_worse)

        actions.select_default:replace(function()
          local entry = action_state.get_selected_entry()
          confirmed = true
          actions.close(prompt_bufnr)
          if entry then
            M.set_default(entry.value)
            vim.notify("Default theme: " .. entry.palette.label, vim.log.levels.INFO)
          end
        end)

        actions.close:enhance({
          post = function()
            if not confirmed then
              vim.schedule(function()
                M.apply(saved_mode)
              end)
            end
          end,
        })

        vim.schedule(preview_selection)
        return true
      end,
    })
    :find()
end

-- Default palette for startup consumers.
M.palette = themes.coral

return M
