-- Find/replace in current buffer or in project, scoped to .rs and .toml (via ripglob).
local M = {}

local delim = "#"

--- Literal whole-buffer replace; returns (new_str, n_replacements).
local function literal_replace_all(data, old, new_)
  if old == "" then
    return data, 0
  end
  local n, i, out = 0, 1, data
  while true do
    local a, b = out:find(old, i, true)
    if not a then
      break
    end
    n = n + 1
    out = out:sub(1, a - 1) .. new_ .. out:sub(b + 1)
    i = a + #new_
  end
  return out, n
end

local function escape_very_no_magic(s)
  s = s:gsub("\\", "\\\\")
  s = s:gsub(delim, "\\" .. delim)
  return s
end

function M.buf_is_rs_or_toml()
  local ft = vim.bo.filetype
  if ft == "rust" or ft == "toml" then
    return true
  end
  local ext = vim.fn.expand("%:e")
  return ext == "rs" or ext == "toml"
end

local function resolve_path(f)
  if vim.fn.filereadable(f) == 1 then
    return f
  end
  return vim.fn.fnamemodify(vim.fn.getcwd() .. "/" .. f, ":p")
end

--- Literal find & replace in the current buffer: shows a preview split, then apply or cancel.
--- Also: `set inccommand=split` gives live preview if you use the command line `:%s/.../.../gc` yourself.
local function substitute_current_buffer()
  vim.ui.input({ prompt = "Search (literal): " }, function(search)
    if search == nil or search == "" then
      return
    end
    vim.ui.input({ prompt = "Replace with: " }, function(repl)
      if repl == nil then
        return
      end
      local bufnr = vim.api.nvim_get_current_buf()
      local old_str = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
      local new_str, n = literal_replace_all(old_str, search, repl)
      if n == 0 then
        vim.notify("No matches in buffer.", vim.log.levels.WARN)
        return
      end
      local split_lines = vim.split(new_str, "\n", { plain = true })
      local maxl = 5000
      local preview_lines = {}
      local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
      if name == "" then
        name = "[No Name]"
      end
      table.insert(
        preview_lines,
        ("[Preview: %d replacement(s)]  %s — choose Apply or Cancel"):format(n, name)
      )
      table.insert(preview_lines, "")
      local total_ln = #split_lines
      for i = 1, math.min(maxl, total_ln) do
        table.insert(preview_lines, split_lines[i])
      end
      if total_ln > maxl then
        table.insert(preview_lines, ("… %d more lines not shown"):format(total_ln - maxl))
      end
      local orig_win = vim.api.nvim_get_current_win()
      vim.cmd("belowright 16new")
      local pwin = vim.api.nvim_get_current_win()
      local pbuf = vim.api.nvim_get_current_buf()
      vim.bo[pbuf].buftype = "nofile"
      vim.bo[pbuf].bufhidden = "wipe"
      vim.bo[pbuf].swapfile = false
      local ft = vim.bo[bufnr].filetype
      if ft and ft ~= "" then
        vim.bo[pbuf].filetype = ft
      end
      vim.bo[pbuf].modifiable = true
      vim.api.nvim_buf_set_lines(pbuf, 0, -1, false, preview_lines)
      vim.bo[pbuf].modifiable = false
      vim.api.nvim_set_current_win(orig_win)
      vim.schedule(function()
        vim.ui.select({ "Apply replace to buffer", "Cancel" }, {
          prompt = "Replace " .. n .. " occurrence(s) in this file? (see preview split)",
        }, function(choice)
        if vim.api.nvim_win_is_valid(pwin) then
          pcall(vim.api.nvim_win_close, pwin, true)
        end
        if choice ~= "Apply replace to buffer" then
          return
        end
        if vim.api.nvim_buf_is_valid(bufnr) then
          vim.api.nvim_buf_set_lines(
            bufnr,
            0,
            -1,
            false,
            vim.split(new_str, "\n", { plain = true })
          )
        end
      end)
      end)
    end)
  end)
end

function M.replace_in_file()
  if not M.buf_is_rs_or_toml() then
    vim.notify("Find/replace in file: use a .rs or .toml buffer (or set filetype).", vim.log.levels.WARN)
    return
  end
  substitute_current_buffer()
end

--- Find & replace in the **current file** (any buffer type suitable for editing).
function M.replace_in_buffer()
  local bt = vim.bo.buftype
  if bt == "terminal" or bt == "prompt" then
    vim.notify("Find/replace: not in terminal/prompt buffers; open a file buffer.", vim.log.levels.WARN)
    return
  end
  if vim.bo.readonly then
    vim.notify("Find/replace: buffer is readonly (`set noreadonly` or use `w!`).", vim.log.levels.WARN)
    return
  end
  substitute_current_buffer()
end

function M.find_in_project()
  if vim.fn.executable("rg") ~= 1 then
    vim.notify("ripgrep (rg) required. Scoped to *.rs and *.toml.", vim.log.levels.ERROR)
    return
  end
  require("telescope.builtin").live_grep({
    prompt_title = "Grep in *.rs and *.toml",
    additional_args = { "-g", "*.rs", "-g", "*.toml" },
  })
end

--- Live grep across the whole project (any file `rg` searches; honors .gitignore).
function M.find_in_project_all()
  if vim.fn.executable("rg") ~= 1 then
    vim.notify("ripgrep (rg) required for project search.", vim.log.levels.ERROR)
    return
  end
  require("telescope.builtin").live_grep({
    prompt_title = "Grep in project (all files)",
  })
end

local function replace_in_paths(paths, search, repl, file_desc)
  if #paths == 0 then
    vim.notify("No files contain that text.", vim.log.levels.WARN)
    return
  end
  local details = {}
  local total = 0
  for _, f in ipairs(paths) do
    local p = resolve_path(f)
    if vim.fn.filereadable(p) ~= 1 then
      goto continue
    end
    local data = table.concat(vim.fn.readfile(p), "\n")
    local _, n = literal_replace_all(data, search, repl)
    if n > 0 then
      table.insert(details, { path = p, n = n })
      total = total + n
    end
    ::continue::
  end
  if total == 0 then
    vim.notify("No occurrences to replace (read-only or no match).", vim.log.levels.WARN)
    return
  end
  local preview = {
    ("[Project replace preview] %s"):format(file_desc:gsub("^%s", "")),
    string.format("Total: %d replacement(s) in %d file(s)", total, #details),
    "Search:  " .. search,
    "Replace: " .. repl,
    "",
  }
  for _, d in ipairs(details) do
    table.insert(preview, ("  %dx  %s"):format(d.n, d.path))
  end
  local orig_win = vim.api.nvim_get_current_win()
  vim.cmd("belowright 12new")
  local pwin = vim.api.nvim_get_current_win()
  local pbuf = vim.api.nvim_get_current_buf()
  vim.bo[pbuf].buftype = "nofile"
  vim.bo[pbuf].bufhidden = "wipe"
  vim.bo[pbuf].swapfile = false
  vim.bo[pbuf].modifiable = true
  vim.api.nvim_buf_set_lines(pbuf, 0, -1, false, preview)
  vim.bo[pbuf].modifiable = false
  vim.api.nvim_set_current_win(orig_win)
  vim.schedule(function()
    vim.ui.select({ "Write files (apply replace)", "Cancel" }, {
      prompt = "Confirm " .. #details .. " file(s) on disk? (see preview split)",
    }, function(choice)
      if vim.api.nvim_win_is_valid(pwin) then
        pcall(vim.api.nvim_win_close, pwin, true)
      end
      if choice ~= "Write files (apply replace)" then
        return
      end
      local wr = 0
      for _, d in ipairs(details) do
        local p = d.path
        if vim.fn.filereadable(p) ~= 1 then
          goto c2
        end
        local data = table.concat(vim.fn.readfile(p), "\n")
        local new, n = literal_replace_all(data, search, repl)
        if n > 0 then
          wr = wr + 1
          local out_lines = vim.split(new, "\n", { plain = true })
          vim.fn.writefile(out_lines, p)
        end
        ::c2::
      end
      if wr > 0 then
        vim.notify(
          string.format("Wrote %d file(s), %d replacement(s)%s.", wr, total, file_desc),
          vim.log.levels.INFO
        )
      end
    end)
  end)
end

function M.replace_in_project()
  if vim.fn.executable("rg") ~= 1 then
    vim.notify("ripgrep (rg) required for project replace.", vim.log.levels.ERROR)
    return
  end
  vim.ui.input({ prompt = "Search in *.rs + *.toml (literal): " }, function(search)
    if search == nil or search == "" then
      return
    end
    vim.ui.input({ prompt = "Replace with: " }, function(repl)
      if repl == nil then
        return
      end
      local paths = vim.fn.systemlist({
        "rg",
        "-F",
        "-l",
        "-g",
        "*.rs",
        "-g",
        "*.toml",
        "--",
        search,
        ".",
      })
      if vim.v.shell_error ~= 0 and #paths == 0 then
        vim.notify("rg failed. Run from the project root (or fix ripgrep).", vim.log.levels.WARN)
        return
      end
      replace_in_paths(paths, search, repl, " (*.rs / *.toml)")
    end)
  end)
end

--- Literal replace in every file under cwd that `rg` lists (full project, respects .gitignore).
function M.replace_in_project_all()
  if vim.fn.executable("rg") ~= 1 then
    vim.notify("ripgrep (rg) required for project replace.", vim.log.levels.ERROR)
    return
  end
  vim.ui.input({ prompt = "Search in project (literal, all files): " }, function(search)
    if search == nil or search == "" then
      return
    end
    vim.ui.input({ prompt = "Replace with: " }, function(repl)
      if repl == nil then
        return
      end
      local paths = vim.fn.systemlist({ "rg", "-F", "-l", "--", search, "." })
      if vim.v.shell_error ~= 0 and #paths == 0 then
        vim.notify("rg failed. Run from the project root (or fix ripgrep).", vim.log.levels.WARN)
        return
      end
      replace_in_paths(paths, search, repl, " (all matching files)")
    end)
  end)
end

return M
