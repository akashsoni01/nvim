-- Cycle Averia Libre + JetBrains Nerd as fallback. Names use underscores for spaces (:h guifont).
-- If a face does not load in your GUI, run `fc-list | grep -i averia` and fix `variants[n].spec`.
local M = {}

---@type { name: string, spec: string }[]
M.variants = {
  { name = "light", spec = "Averia_Libre_Light" },
  { name = "regular", spec = "Averia_Libre" },
  { name = "bold", spec = "Averia_Libre_Bold" },
  { name = "light-italic", spec = "Averia_Libre_Light_Italic" },
  { name = "regular-italic", spec = "Averia_Libre_Italic" },
  { name = "bold-italic", spec = "Averia_Libre_Bold_Italic" },
}

M.fallback_spec = "JetBrainsMono Nerd Font"
M.size_min = 6
M.size_max = 32

function M.guifont_string(variant_index, size)
  local v = M.variants[variant_index]
  if not v then
    return nil
  end
  return ("%s:h%d,%s:h%d"):format(v.spec, size, M.fallback_spec, size)
end

function M.apply(variant_index, size)
  local s = M.guifont_string(variant_index, size)
  if s then
    vim.o.guifont = s
    pcall(vim.cmd, "redraw!")
  end
end

function M.init_from_g()
  local n = #M.variants
  local idx = vim.g.averia_variant_idx
  if type(idx) ~= "number" or idx < 1 or idx > n then
    idx = 2
  end
  local sz = vim.g.averia_font_size
  if type(sz) ~= "number" or sz < M.size_min or sz > M.size_max then
    sz = 13
  end
  vim.g.averia_variant_idx = idx
  vim.g.averia_font_size = sz
  M.apply(idx, sz)
end

--- Move to the "next" or "previous" style in the list (wraps). +1 = "below" in the CSS list.
function M.cycle_style(delta)
  local n = #M.variants
  local idx = vim.g.averia_variant_idx
  if type(idx) ~= "number" or idx < 1 or idx > n then
    idx = 2
  end
  local sz = vim.g.averia_font_size
  if type(sz) ~= "number" or sz < M.size_min or sz > M.size_max then
    sz = 13
  end
  local next_idx = (idx - 1 + (delta or 1)) % n + 1
  vim.g.averia_variant_idx = next_idx
  M.apply(next_idx, sz)
  local label = M.variants[next_idx].name
  vim.notify(("Font: %s, %dpt"):format(label, sz), vim.log.levels.INFO)
end

function M.cycle_size(delta)
  local idx = vim.g.averia_variant_idx
  local n = #M.variants
  if type(idx) ~= "number" or idx < 1 or idx > n then
    idx = 2
  end
  local sz = vim.g.averia_font_size
  if type(sz) ~= "number" or sz < M.size_min or sz > M.size_max then
    sz = 13
  end
  local next_size = math.max(M.size_min, math.min(M.size_max, sz + (delta or 0)))
  if next_size == sz and (delta or 0) ~= 0 then
    return
  end
  vim.g.averia_font_size = next_size
  M.apply(idx, next_size)
  vim.notify(
    ("Font: %s, %dpt"):format(M.variants[idx].name, next_size),
    vim.log.levels.INFO
  )
end

return M
