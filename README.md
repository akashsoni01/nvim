# Neovim Rust Setup (Termux)

This config is a `lazy.nvim`-based Neovim setup focused on Rust development in Termux.

## Highlights
- Coral default + 15 color families — pick with `<leader>ul` (30 themes: all dark, then all bright)
- Rust LSP (`rust-analyzer`) + completion + snippets
- Treesitter syntax highlighting and rustfmt on save
- DAP debugging support for LLDB adapters
- Telescope/Git/LSP/testing keymaps

## Docs
- Full shortcut + workflow guide: [`RUST_NEOVIM_CHEATSHEET.md`](./RUST_NEOVIM_CHEATSHEET.md)
- Script reference: [`scripts/README.md`](./scripts/README.md)

## Offline Mode (Vendor Plugins)
- Run once while online:
  - `bash ./scripts/vendor-plugins.sh`
- This vendors `lazy.nvim` and plugin repos into:
  - `vendor/lazy/lazy.nvim`
  - `vendor/plugins/*`
- After that, this config prefers local vendor paths automatically, so Neovim can start offline.
- The vendor script defaults to `--locked`: it checks out plugin commits from `lazy-lock.json`.
- Use `bash ./scripts/vendor-plugins.sh --latest` only during an intentional plugin update/review window.
- If you add new plugins later, run the vendor script again.
- Remove vendored plugin repos:
  - `bash ./scripts/remove-vendor.sh`
- Check Git worktree support anytime with:
  - `bash ./scripts/check-worktree.sh`
- Step-by-step vendoring guide: [`RUST_NEOVIM_CHEATSHEET.md`](./RUST_NEOVIM_CHEATSHEET.md) (section **Offline / Vendor Plugins**)

## Private mirror: AWS, internal git, or other repos

Use this when machines cannot reach GitHub but can reach **your** storage (S3, CodeCommit, GitLab, Gitea, Artifactory, etc.).

### How local loading works (no GitHub at runtime)

`lua/config/lazy.lua` checks disk first:

| Path | Role |
|---|---|
| `vendor/lazy/lazy.nvim` | `lazy.nvim` manager |
| `vendor/plugins/<name>/` | One git checkout per plugin |

If those folders exist, Neovim loads plugins from **local directories** — not from GitHub. Pair with corporate mode so nothing is downloaded at startup:

```bash
NVIM_CORPORATE_MODE=1 nvim .
```

### Option A — Private git repo (recommended for teams)

Best when you already host dotfiles or internal tooling in git.

**On a connected build machine (once per release):**

```bash
cd ~/.config/nvim
bash ./scripts/vendor-plugins.sh --locked
git add vendor/ lazy-lock.json
git commit -m "Vendor plugins at lazy-lock pins"
git push origin main    # your private GitHub / GitLab / CodeCommit remote
```

**On each laptop / Termux / CI runner:**

```bash
git clone git@your-internal-host:team/nvim-config.git ~/.config/nvim
# or: git pull in an existing clone
NVIM_CORPORATE_MODE=1 nvim .
:Lazy    # plugins should show local/vendor source, not Failed
```

Tips:
- Commit the whole `vendor/` tree (or use **Git LFS** if your org requires it for large trees).
- Tag releases (`nvim-vendor-2025-06-07`) so air-gapped hosts can checkout a reviewed snapshot.
- Never run `vendor-plugins.sh --latest` on production machines; only on the build machine after review.

### Option B — AWS S3 tarball (good for air-gapped / Termux bulk deploy)

**1. Build the vendor bundle (connected machine):**

```bash
cd ~/.config/nvim
bash ./scripts/vendor-plugins.sh --locked

RELEASE="nvim-config-$(date +%Y%m%d)"
tar -czf "/tmp/${RELEASE}.tar.gz" \
  --exclude='.git' \
  -C "$(dirname "$PWD")" "$(basename "$PWD")"
```

The archive should include at least: `vendor/`, `lazy-lock.json`, `lua/`, `init.lua`, `scripts/`.

**2. Upload to S3:**

```bash
aws s3 cp "/tmp/${RELEASE}.tar.gz" "s3://YOUR-BUCKET/nvim/${RELEASE}.tar.gz"
# optional integrity file:
shasum -a 256 "/tmp/${RELEASE}.tar.gz" | tee "/tmp/${RELEASE}.tar.gz.sha256"
aws s3 cp "/tmp/${RELEASE}.tar.gz.sha256" "s3://YOUR-BUCKET/nvim/${RELEASE}.tar.gz.sha256"
```

Use your org's KMS, bucket policy, and VPC endpoint rules as required.

**3. Download and install (target machine):**

```bash
aws s3 cp "s3://YOUR-BUCKET/nvim/${RELEASE}.tar.gz" /tmp/
aws s3 cp "s3://YOUR-BUCKET/nvim/${RELEASE}.tar.gz.sha256" /tmp/
cd /tmp && shasum -a 256 -c "${RELEASE}.tar.gz.sha256"

mkdir -p ~/.config
tar -xzf "/tmp/${RELEASE}.tar.gz" -C ~/.config
NVIM_CORPORATE_MODE=1 nvim .
```

On Termux, use the same flow after `pkg install aws-cli` (or copy the tarball in over `scp`/`adb push` if AWS CLI is not available).

### Option C — Mirror each plugin repo (CodeCommit / GitLab / Gitea)

Use when policy requires every upstream plugin to live in **your** git forge, not only a tarball.

**1. Mirror upstream repos (build machine, one-time per plugin):**

`scripts/vendor-plugins.sh` clones from `https://github.com/<owner>/<repo>.git`. Mirror each entry in its `repos=(...)` list to your internal remote with the **same repo name** (e.g. `nvim-cmp`).

Example pattern (GitLab):

```bash
git clone --mirror "https://github.com/hrsh7th/nvim-cmp.git"
cd nvim-cmp.git
git remote add internal "git@gitlab.internal:tools/nvim-cmp.git"
git push --mirror internal
```

Repeat for `folke/lazy.nvim` and every plugin in `scripts/vendor-plugins.sh`.

**2. Point vendoring at your mirror**

Edit `clone_or_update()` in `scripts/vendor-plugins.sh` and replace the GitHub URL with your base URL, for example:

```bash
# was: url="https://github.com/${repo}.git"
url="https://git-codecommit.us-east-1.amazonaws.com/v1/repos/${repo##*/}"
# or: url="https://gitlab.internal/tools/${repo##*/}.git"
```

Then vendor from the mirror:

```bash
bash ./scripts/vendor-plugins.sh --locked
```

**3. Distribute** using Option A (git) or Option B (S3).

### Option D — Object storage without git history (S3 / MinIO / Artifactory raw)

If you only store **directories** (not git clones), sync the vendored tree:

```bash
# upload after vendoring
aws s3 sync ~/.config/nvim/vendor/ "s3://YOUR-BUCKET/nvim/vendor/" --delete

# download on target
aws s3 sync "s3://YOUR-BUCKET/nvim/vendor/" ~/.config/nvim/vendor/
```

You still need `lazy-lock.json` and the rest of the config locally. Prefer Option B tarball unless you have an automated sync job.

### Verify plugins load from local mirror

```bash
NVIM_CORPORATE_MODE=1 nvim .
:Lazy
```

Healthy signs:
- `lazy.nvim` and plugins show **loaded** or **not loaded** (lazy triggers) — not **Failed** / **not installed**
- Plugin rows mention `vendor/plugins/...` as the source
- `:checkhealth lazy` is clean

If a plugin is missing:

```bash
ls ~/.config/nvim/vendor/plugins/<plugin-name>
bash ~/.config/nvim/scripts/vendor-plugins.sh --locked
```

### Release checklist (internal mirror)

1. Update plugins on a connected machine (`NVIM_VIM_FORCE=1 nvim .` → `:Lazy update` if needed).
2. `bash ./scripts/vendor-plugins.sh --locked`
3. Test `NVIM_CORPORATE_MODE=1 nvim .` and `:Lazy`
4. Publish (private git tag, S3 tarball, or per-repo mirror push)
5. Document the version/tag for air-gapped hosts
6. On targets: pull/sync only — do not re-vendor from GitHub

## Enterprise Defaults (`NVIM_VIM_FORCE`)
- Plain `nvim .` starts in enterprise-safe mode. External read/write integrations stay off unless you opt in.
- Enable clipboard, filesystem completions, plugin downloads, and rust proc-macro execution:
  - `NVIM_VIM_FORCE=1 nvim .`
- Disabled without `NVIM_VIM_FORCE=1`:
  - Linux clipboard (`wl-clipboard`, `xclip`, `xsel`) and `+` register keymaps (`<leader>yf`, `<leader>pf`, `<leader>p`, …)
  - `cmp-path` and `crates.nvim` completion sources
  - `lazy.nvim` missing-plugin downloads and luarocks
  - `rust-analyzer` proc macros and check-on-save
  - `scripts/install-debug-adapter-linux.sh` network download fallback for `codelldb`
- Linux clipboard providers are never auto-installed. Install `wl-clipboard` or `xclip`/`xsel` yourself, then use `NVIM_VIM_FORCE=1`.

## Neovim-Only Workspace (manual)
- Plain `nvim .` does **not** change IDE/LLM settings — use `NVIM_VIM_ONLY` when you want to mark or unmark.
- Mark and block Cursor, VS Code, JetBrains, and LLM indexing:
  - `NVIM_VIM_ONLY=1 nvim .`
- While Neovim is open (with `NVIM_VIM_ONLY=1` or `2`), IDE marker files (`.vscode`, `.cursor`, ignore files) are stashed under `~/.config/nvim/.vim-only-stash/`.
- When Neovim exits, markers are restored so other IDEs stay blocked.
- Restore IDE indexing for a project:
  - `NVIM_VIM_ONLY=0 nvim .`
- Enhanced Claude/parent blocking:
  - `NVIM_VIM_ONLY=2 nvim .` — also marks parent `super/`, adds Claude ignores, and keeps all LLM/editor blocker files on disk while Neovim runs
- Blocked tools include Cursor, VS Code, Claude Code, Copilot, Windsurf, Zed, Continue, Codeium, Cody, Tabnine, Aider, Roo/Cline, Gemini, JetBrains Junie/Fleet, PearAI, IDX, Codex, OpenHands, Devin, and other common AI editors
- Inside Neovim:
  - `:VimOnlyMark` — mark + stash now
  - `:VimOnlyReset` — remove all markers and restore IDE indexing

## Corporate Mode
- Start with:
  - `NVIM_CORPORATE_MODE=1 nvim .`
- Corporate mode requires vendored `lazy.nvim` and plugins; it does not fall back to downloaded lazy data or install missing plugins.
- Rust project code execution also requires force mode and an explicit trust flag:
  - `NVIM_VIM_FORCE=1 NVIM_CORPORATE_MODE=1 NVIM_TRUST_RUST_PROJECT=1 nvim .`
- For Linux `codelldb` fallback downloads in corporate mode, pin and verify the binary:
  - `NVIM_VIM_FORCE=1 CODELLDB_URL=... CODELLDB_SHA256=... NVIM_CORPORATE_MODE=1 ./scripts/install-debug-adapter-linux.sh`

## Scripts
| Script | Purpose |
|---|---|
| `scripts/nvim-workspace.sh` | Universal `nvim` wrapper; documents env vars |
| `scripts/install-nvim-wrapper.sh` | Install shell `nvim()` function + wrapper binary |
| `scripts/mark-vim-only-project.sh` | Write IDE/LLM blockers to stash and deploy |
| `scripts/unmark-vim-only-project.sh` | Remove blockers and stash for a project |
| `scripts/vim-only-stash.sh` | `stash` / `restore` / `deploy` IDE marker files |
| `scripts/vendor-plugins.sh` | Vendor `lazy.nvim` and plugins for offline/corporate use |
| `scripts/install-debug-adapter-linux.sh` | Install LLDB DAP adapter (network fallback needs `NVIM_VIM_FORCE=1`) |
| `scripts/uninstall-deps.sh` | Remove config-managed debug adapters |
| `scripts/check-worktree.sh` | Verify git worktree support |

## Cleanup / Uninstall Scripts
- Remove local vendored plugin sources:
  - `bash ./scripts/remove-vendor.sh`
- Remove config-managed debug adapter shims and downloaded `codelldb` files:
  - `bash ./scripts/uninstall-deps.sh`
- Also try package-manager uninstall for `llvm`/`lldb`:
  - `bash ./scripts/uninstall-deps.sh --system`

## Beginner: Open and Navigate a Project

### 1) Open Neovim in your project folder
- From Termux:
  - `cd /path/to/your/rust-project`
  - `nvim .`
- This opens Neovim with your project as the current workspace.

### 2) Find and open files quickly
- `<leader>ff` - Find files in project
- `<leader>fg` - Search text in project (live grep)
- `<leader>fc` - Search text in current file
- `<leader>fb` - Switch between open buffers
- `<leader>fh` - Search Neovim help tags

### 3) Basic movement inside a file
- `h` `j` `k` `l` - left/down/up/right
- `w` / `b` - next/previous word
- `gg` / `G` - top/bottom of file
- `/text` then `n` / `N` - search and jump next/previous match (normal mode only; visual `/` is block comment — see below)

### 3b) Block comments (visual mode)
- Select lines with `v`, `V`, or `<C-v>`
- Press `/` to wrap the selection with `/* */`
- Press `/` again on the same block to uncomment

### 4) Work with multiple files and splits
- `<leader>sv` - Open vertical split
- `<leader>sh` - Open horizontal split
- `<leader>se` - Equalize split sizes
- `<leader>sx` - Close current split
- Move between splits with `Ctrl-w` then `h/j/k/l`

### 5) Navigate Rust code with LSP
- `gd` / `<leader>ld` - Jump to definition (works in vertical splits)
- `gpd` / `<leader>lD` - Show definition (peek float)
- `gr` - Find references
- `K` - Hover documentation
- `<leader>rn` - Rename symbol project-wide

### 6) First useful workflow (recommended)
1. Open project: `nvim .`
2. Find file: `<leader>ff`
3. Jump to definition: `gd`
4. Fix issues with code actions: `<leader>ca`
5. Save to format (`rustfmt` runs on save)
6. Before commit: `<leader>ga` (save all → `cargo fmt` → `git add .`)

## Big Table: Widely Used Commands

| Category | Command / Key | What it does | Beginner tip |
|---|---|---|---|
| Open Project | `nvim .` | Open Neovim in current folder | Run this from your Rust project root |
| Quit | `:q` | Quit current window | If unsaved, use `:q!` to force |
| Save | `:w` | Save current file | Use often while learning |
| Save + Quit | `:wq` | Save then quit | Fast exit command |
| Force Quit | `:q!` | Quit without saving | Discards unsaved changes |
| Move | `h` `j` `k` `l` | Left/down/up/right | Think of `j` as down arrow |
| Word Jump | `w` | Move to next word start | Great for quick code movement |
| Word Back | `b` | Move to previous word start | Use with `w` together |
| Line Start | `0` | Jump to start of line | `^` jumps first non-space |
| Line End | `$` | Jump to end of line | Useful before appending text |
| File Top | `gg` | Jump to top of file | Press twice quickly |
| File Bottom | `G` | Jump to bottom of file | Good for logs and long files |
| Search Forward | `/text` | Search forward for text | Press `n` for next result |
| Search Backward | `?text` | Search backward for text | Press `N` for opposite direction |
| Next Match | `n` | Next search result | Works after `/` or `?` |
| Previous Match | `N` | Previous search result | Reverse direction |
| Insert Mode | `i` | Insert before cursor | Most common editing mode |
| Append | `a` | Insert after cursor | Faster than moving then `i` |
| New Line Below | `o` | New line below and insert | Good for writing code quickly |
| New Line Above | `O` | New line above and insert | Useful in function headers |
| Undo | `u` | Undo last change | Press multiple times for history |
| Redo | `<C-r>` | Redo undone change | Opposite of undo |
| Copy Line | `yy` | Yank (copy) line | Use count like `3yy` |
| Copy Full File | `<leader>yf` | Yank entire file to clipboard | Requires `NVIM_VIM_FORCE=1`; native alt: `ggyG` |
| Paste Full File | `<leader>pf` | Replace buffer with clipboard | Requires `NVIM_VIM_FORCE=1` |
| Cut Full File | `<leader>xf` | Cut entire file to clipboard | Requires `NVIM_VIM_FORCE=1` |
| Paste | `p` or `<leader>p` | Paste after cursor | `P` / `<leader>P` paste before cursor |
| Delete Line | `dd` | Delete current line | Use count like `2dd` |
| Change Word | `ciw` | Replace word under cursor | Very common refactor action |
| Command Mode | `:` | Enter command-line mode | Run Ex commands from here |
| File Finder | `<leader>ff` | Telescope find files | Main way to open project files |
| Live Grep | `<leader>fg` | Telescope text search | Search symbols across project |
| Buffer Search | `<leader>fc` | Search text in current file | Fuzzy find in open buffer; no `rg` needed |
| Find in `*.rs` / `*.toml` | `<leader>sg` | Telescope `live_grep` with `rg` globs | Project search only in Rust and TOML files (needs `rg`) |
| Find in any file in project | `<leader>fA` or `<leader>fg` | Telescope `live_grep` (no ext filter) | Same behavior; all text files (needs `rg`; respects `.gitignore`) |
| Find word in project | `<leader>fW` or `:FW` | Normal: word under cursor in project; Visual: selection in current buffer only |
| Replace in any file in project | `<leader>sA` | Literal string replace in every file `rg` lists | All matching files under cwd; needs `rg`; reload buffers; use with care |
| Find & replace in **one** file (any) | `<leader>sr` | Literal `:%s/.../.../gc` with confirm | Current buffer only; any normal file; not terminal/readonly |
| Replace in `*.rs` / `*.toml` (buffer) | `<leader>sf` | Same as `sr`, scoped to Rust/TOML buffers only | Use `sr` for other file types |
| Replace in `*.rs` / `*.toml` (project) | `<leader>sR` | Literal replace on disk in all matches | All matching files from cwd; needs `rg`; reload buffers after |
| Buffers | `<leader>fb` | List open buffers | Quick file switching |
| Help Search | `<leader>fh` | Search help docs | Learn Neovim interactively |
| Vertical Split | `<leader>sv` | Open vertical split | Compare files side-by-side |
| Horizontal Split | `<leader>sh` | Open horizontal split | Useful for terminal + code |
| Equalize Splits | `<leader>se` | Make split sizes equal | Fix uneven layout quickly |
| Close Split | `<leader>sx` | Close current split | Safe cleanup |
| Split Navigation | `<C-w> h/j/k/l` | Move between windows | Core multi-pane workflow |
| Jump to Definition | `gd` / `<leader>ld` | Jump to symbol definition | Safe in vertical splits; 8s timeout if indexing |
| Show Definition | `gpd` / `<leader>lD` | Peek definition in float | Stay in place, press `q` to close |
| Block Comment | `/` (visual) | Toggle `/* */` on selected lines | Use `V` for line-wise selection; normal `/` still searches |
| References | `gr` | Show symbol references | Great for safe refactors |
| Hover Docs | `K` | Show docs for symbol | API info without leaving file |
| Signature Help | `<C-k>` | Show function parameters | Helpful while typing calls |
| Code Action | `<leader>ca` | LSP fixes/actions | Auto-imports and quick fixes |
| Rename Symbol | `<leader>rn` | Rename symbol project-wide | Safer than manual rename |
| Format Buffer | `<leader>fm` | Format current file | Rustfmt also runs on save |
| Next Error | `<leader>len` | Jump to next current/cached error | Opens full diagnostic float |
| Previous Error | `<leader>lep` | Jump to previous current/cached error | Opens full diagnostic float |
| Next Warning | `<leader>lwn` | Jump to next current/cached warning | Opens full diagnostic float |
| Previous Warning | `<leader>lwp` | Jump to previous current/cached warning | Opens full diagnostic float |
| Next Error File | `<leader>lfe` | Telescope list of all compile errors | Runs `cargo check`; full log in preview |
| Current Error List | `<leader>lee` | Telescope list of current/cached errors | Reuses last `lfe`; full log in preview |
| Previous Error File | `<leader>lfE` | Jump to previous error file | After `lfe`, or uses cargo + LSP list |
| Next Warning File | `<leader>lfw` | Telescope list of all warnings | Same as errors, full log in preview |
| Current Warning List | `<leader>lww` | Telescope list of current/cached warnings | Reuses last `lfw`; full log in preview |
| Previous Warning File | `<leader>lfW` | Open previous file with warning | Sorted by file path |
| Parent Rust Folder | `nvim .` from parent | Check direct child crates like `1/` and `2/` | Used by `<leader>lfe` / `<leader>lfw` |
| Toggle Breakpoint | `<leader>db` | Add/remove debugger breakpoint | Start debugging flow |
| Debug Continue | `<leader>dc` | Continue/start debugger | Launches DAP session |
| Step Over | `<leader>do` | Debug step over line | Skip entering function calls |
| Step Into | `<leader>di` | Debug step into function | Inspect deeper behavior |
| Git Status | `<leader>gs` | Telescope git status | See changed files quickly |
| Git Commits | `<leader>gl` | Telescope commit history | Browse recent commits |
| Git Diff | `<leader>gd` | Diff current file | Review current changes |
| Git Branches | `<leader>gb` | Telescope git branches | Switch or inspect branches |
| Git Buffer Commits | `<leader>gC` | Telescope commits for current file | See file-specific history |
| Git Checkout | `<leader>gco` or `:GitCheckout [branch]` | Run `git checkout <branch>` | Switch the current repo to another branch |
| Git Fetch | `<leader>gf` or `:GitFetch` | Run `git fetch --all --prune` | Update remote refs before branching |
| Git Pull | `<leader>gpl` or `:GitPull` | Run `git pull --ff-only` | Update current branch safely |
| Git Push | `<leader>gps` or `:GitPush` | Run `git push` | Push current branch |
| Git Stash | `<leader>gS` or `:GitStash` | Run `git stash push -u` | Save dirty work including untracked files |
| Git Stash List | `<leader>gL` or `:GitStashList` | Run `git stash list` | Review saved stashes |
| Git Stage Prep | `<leader>ga` | Save all → `cargo fmt` → `git add .` | One-key pre-commit workflow |
| Git Stash Apply | `<leader>gA` | Run `git stash apply` | Reapply latest stash |
| Git Hunk Preview | `<leader>ghp` | Preview current hunk | Inspect nearby changes inline |
| Git Hunk Stage | `<leader>ghs` | Stage current hunk | Commit part of a file |
| Git Hunk Reset | `<leader>ghr` | Reset current hunk | Discard one local hunk |
| Git Hunk Blame | `<leader>ghb` | Blame current line | See who last changed a line |
| Git Worktree Create | `<leader>gwc` | Run `git worktree add <path> [branch]` | Create another checkout for an existing branch or commit |
| Git Worktree Branch | `<leader>gwb` | Run `git worktree add -b <branch> <path>` | Create a new branch and checkout together |
| Git Worktree List | `<leader>gwl` | Run `git worktree list` | See all linked worktrees |
| Git Worktree Switch | `<leader>gws` or `:GitWorktreeSwitch` | Change Neovim cwd to a selected worktree | Move this Neovim session to another checkout |
| Git Worktree Delete | `<leader>gwd` | Run `git worktree remove <path>` | Delete a worktree path after cleanup |
| Run Test | `<leader>tt` | Run nearest Rust test | Fast feedback loop |
| Run All Tests | `<leader>ta` | Run full test suite | Use before commits |
| Test Output | `<leader>to` | Toggle test output panel | Debug failed tests |
| Test Summary | `<leader>ts` | Toggle test summary | See pass/fail overview |
| Cargo Clippy | `<leader>tc` | Run clippy with all targets/features | Catch lint issues early |
| Cargo Fmt | `<leader>tf` | Run `cargo fmt` on the project | Format whole crate before commit |
| Cargo Run | `<leader>tr` | Run Rust app | Quick manual verification |
| Select Theme | `<leader>ul` | Telescope picker for all 30 themes | Dark block first; Xcode2 tuned for macOS Terminal |
| Toggle Transparency | `<leader>ut` | Enable/disable transparent bg | Useful per terminal theme |
| Toggle Inlay Hints | `<leader>uh` | Show/hide Rust inlay hints | Reduce visual noise when needed |

## Git Worktree: What to Use When

| Use case | Shortcut | Command pattern |
|---|---|---|
| Work on an existing branch in a second folder | `<leader>gwc` | `git worktree add <path> <branch>` |
| Create a fresh branch and a worktree together | `<leader>gwb` | `git worktree add -b <new-branch> <path> [start-point]` |
| Check which worktrees exist before switching or deleting | `<leader>gwl` | `git worktree list` |
| Move Neovim to another existing worktree | `<leader>gws` | `:cd <selected-worktree>` |
| Delete a finished worktree folder | `<leader>gwd` | `git worktree remove <path>` |

Aliases: `<leader>gwa` also creates/adds a worktree, and `<leader>gwr` also removes/deletes one.

## Git Shortcuts: What to Use When

| Use case | Shortcut | Command pattern |
|---|---|---|
| Browse changed files | `<leader>gs` | `Telescope git_status` |
| Browse branches | `<leader>gb` | `Telescope git_branches` |
| Switch branch in the current checkout | `<leader>gco` | `git checkout <branch>` |
| Update remote branch info | `<leader>gf` | `git fetch --all --prune` |
| Update your current branch | `<leader>gpl` | `git pull --ff-only` |
| Push current branch | `<leader>gps` | `git push` |
| Save unfinished dirty work | `<leader>gS` | `git stash push -u` |
| Format and stage everything before commit | `<leader>ga` | `:wa` → `cargo fmt` → `git add .` |
| Commit only part of a file | `<leader>ghs` | Gitsigns stage hunk |
| Discard one bad hunk | `<leader>ghr` | Gitsigns reset hunk |
| Check why a line changed | `<leader>ghb` | Gitsigns blame line |

## Environment flags (quick reference)

| Flag | Example | Effect |
|---|---|---|
| (default) | `nvim .` | Enterprise-safe; no IDE/LLM changes unless you set `NVIM_VIM_ONLY` |
| `NVIM_VIM_FORCE` | `NVIM_VIM_FORCE=1 nvim .` | Clipboard, external completions, proc macros |
| `NVIM_VIM_ONLY` | off (no change on `nvim .`) | `1` = mark; `0` = unmark; `2` = enhanced block |
| `NVIM_CORPORATE_MODE` | `NVIM_CORPORATE_MODE=1 nvim .` | Require local `vendor/`; block lazy downloads |
| `NVIM_LIGHT` | `NVIM_LIGHT=1 nvim .` | Low-memory rust-analyzer; skip `target/` in grep |
| `NVIM_RA_LINK_ALL` | with light/big monorepo | Load all sibling crates for cross-crate `gd` |
| `NVIM_TRUST_RUST_PROJECT` | with force + corporate | Allow rust proc macros on trusted repos |

NVIM_VIM_FORCE=1 NVIM_CORPORATE_MODE=1 nvim .
