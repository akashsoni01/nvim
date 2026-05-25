local M = {}

local function cargo_root_from(path)
  if not path or path == "" then
    return nil
  end

  return vim.fs.root(path, "Cargo.toml")
end

local function child_cargo_roots(cwd)
  local roots = {}
  local ok, iter = pcall(vim.fs.dir, cwd)
  if not ok or not iter then
    return roots
  end

  for name, kind in iter do
    if kind == "directory" then
      local candidate = cwd .. "/" .. name
      if vim.uv.fs_stat(candidate .. "/Cargo.toml") then
        roots[#roots + 1] = candidate
      end
    end
  end

  table.sort(roots)
  return roots
end

local function preferred_child_cargo_root(cwd)
  local roots = child_cargo_roots(cwd)
  if #roots == 0 then
    return nil
  end

  if #roots == 1 then
    return roots[1]
  end

  for _, needle in ipairs({ "binary", "bin", "main", "app" }) do
    for _, root in ipairs(roots) do
      local name = vim.fn.fnamemodify(root, ":t"):lower()
      if name:find(needle, 1, true) then
        return root
      end
    end
  end

  return roots[1]
end

function M.project_root()
  local buffer_path = vim.api.nvim_buf_get_name(0)
  local buffer_root = cargo_root_from(buffer_path)
  if buffer_root then
    return buffer_root
  end

  local cwd = vim.fn.getcwd()
  return cargo_root_from(cwd) or preferred_child_cargo_root(cwd)
end

function M.ensure_cargo()
  if vim.fn.executable("cargo") ~= 1 then
    vim.notify("cargo is not installed or not on PATH.", vim.log.levels.ERROR)
    return nil
  end

  local root = M.project_root()
  if not root then
    vim.notify(
      "No Cargo.toml found. Open a Rust crate, workspace, or parent folder containing a Cargo child project.",
      vim.log.levels.ERROR
    )
    return nil
  end

  return root
end

function M.metadata_ok(root)
  local result = vim.system(
    { "cargo", "metadata", "--no-deps", "--format-version", "1" },
    { cwd = root, text = true, stderr = true }
  ):wait()

  if result.code ~= 0 or not result.stdout or result.stdout == "" then
    local msg = (result.stderr or "") ~= "" and result.stderr or "no output"
    vim.notify(
      "cargo metadata failed in " .. root .. " (neotest-rust needs this).\n" .. msg,
      vim.log.levels.ERROR
    )
    return false
  end

  local ok = pcall(vim.json.decode, result.stdout)
  if not ok then
    vim.notify("cargo metadata returned invalid JSON in " .. root, vim.log.levels.ERROR)
    return false
  end

  return true
end

---@param run_fn fun()
---@param terminal_fallback fun()|nil
function M.run_neotest(run_fn, terminal_fallback)
  local root = M.ensure_cargo()
  if not root then
    return
  end

  if not M.metadata_ok(root) then
    if terminal_fallback then
      terminal_fallback()
    end
    return
  end

  local ok, err = pcall(run_fn)
  if not ok then
    vim.notify(
      "Neotest failed: " .. tostring(err) .. "\nFalling back to terminal cargo test.",
      vim.log.levels.WARN
    )
    if terminal_fallback then
      terminal_fallback()
    end
  end
end

return M
