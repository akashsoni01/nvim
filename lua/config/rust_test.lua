local M = {}

function M.project_root()
  return vim.fs.root(vim.fn.getcwd(), "Cargo.toml")
end

function M.ensure_cargo()
  if vim.fn.executable("cargo") ~= 1 then
    vim.notify("cargo is not installed or not on PATH.", vim.log.levels.ERROR)
    return nil
  end

  local root = M.project_root()
  if not root then
    vim.notify("No Cargo.toml found. cd to your Rust project and run `nvim .`", vim.log.levels.ERROR)
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
