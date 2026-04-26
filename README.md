# Neovim Java setup (Termux / desktop)

A `lazy.nvim`-based Neovim configuration for **Java** development (Maven/Gradle) with LSP, tests, and debugging.

## Highlights

- Coral theme (default) with a light mode toggle
- **jdtls** (Eclipse JDT language server) via [nvim-jdtls](https://codeberg.org/mfussenegger/nvim-jdtls) + completion + snippets
- **Mason** installs `jdtls`, `java-debug-adapter`, and `java-test` (DAP + JUnit integration)
- Tree-sitter highlighting (including `pom.xml` with the `xml` parser)
- `nvim-dap` + `nvim-dap-ui`: run/debug from jdtls (main classes, JUnit) when the Mason bundles are installed
- [neotest](https://github.com/nvim-neotest/neotest) with [neotest-java](https://github.com/rcasia/neotest-java) for the same leader keys as before (`<leader>tt`, etc.)
- Telescope, Git, and LSP keymaps

## Requirements

- **JDK** on `PATH` (eclipse.jdt.ls often runs on **Java 21+**; project code can use older `-target` with `java.configuration.runtimes` in jdtls if needed)
- **`JAVA_HOME`** if your system expects it
- A **Maven** (`pom.xml` / `mvnw`) or **Gradle** (`build.gradle`, `gradlew`) project for full LSP (single orphan `.java` files only get basic features)

## First-time inside Neovim

1. `:Mason` — ensure **jdtls**, **java-debug-adapter**, and **java-test** are installed.
2. Run `:TSInstall java xml` (and sync parsers) if anything is missing.
3. For neotest-java: `:NeotestJava setup` (downloads the JUnit platform JAR; see the plugin README).
4. Open a file under a project root; jdtls attaches on `FileType java` from `ftplugin/java.lua`.
5. After the server and debugger bundles load: use `:JdtUpdateDebugConfig` (or the same via jdtls) if `dap.continue` has no `java` configs yet. Then **`<leader>dc`** to start a debug session from generated configs.
6. Format on save for `*.java` uses LSP (`:lua` → `config/autocmds.lua`).

## Docs

- Shortcuts and workflows: [`JAVA_NEOVIM_CHEATSHEET.md`](./JAVA_NEOVIM_CHEATSHEET.md)

## Offline mode (vendor plugins)

- While online, run: `bash ./scripts/vendor-plugins.sh`
- Vendors `lazy.nvim` and plugin repos into `vendor/`; the config can prefer these paths.
- Re-run when you add or change plugins.
- Remove vendored sources: `bash ./scripts/remove-vendor.sh`
- `bash ./scripts/check-worktree.sh` — git worktree helper

## Cleanup / uninstall

- Remove vendored sources: `bash ./scripts/remove-vendor.sh`
- `bash ./scripts/uninstall-deps.sh` — removes older config-managed codelldb/lldb shims (optional; not required for Java DAP, which comes from Mason)

## Beginner: open a project

### 1) Open Neovim at the project root

```bash
cd /path/to/your/maven-or-gradle-project
nvim .
```

### 2) Find files

- `<leader>ff` — find files
- `<leader>fg` — live grep
- `<leader>fb` — buffers
- `<leader>fh` — help tags

### 3) Basic movement (same as usual Vim)

- `h` / `j` / `k` / `l`, `w` / `b`, `gg` / `G`, `/` search, etc.

### 4) Splits

- `<leader>sv` / `<leader>sh` / `<leader>se` / `<leader>sx`

### 5) LSP (Java)

- `gd` — go to definition
- `gr` — references
- `K` — hover
- `<leader>rn` — rename
- `<leader>ca` — code actions
- `<leader>oi` — organize imports (jdtls, Java buffers)
- `<leader>fm` — format buffer (and format on save for `.java`)

### 6) Suggested first workflow

1. `nvim .` in the repo root
2. Open a `src/.../Something.java` file
3. Wait for jdtls to import the project; use `:JdtCompile` or `:messages` if something fails
4. `<leader>ff` to jump around; `gd` on a type
5. `<leader>tb` to compile, `<leader>tt` to run the nearest test (neotest), `<leader>dc` to continue/start debugging (after DAP is set up)
6. Save to format the buffer

## Big table: common commands

| Category | Key / command | What it does |
| --- | --- | --- |
| Open project | `nvim .` | Open Neovim in the current directory |
| File finder | `<leader>ff` | Telescope find files |
| Live grep | `<leader>fg` | Ripgrep search |
| Go to definition | `gd` | LSP jump |
| Organize imports | `<leader>oi` | jdtls (Java) |
| Format | `<leader>fm` / save `.java` | LSP format |
| Build (compile) | `<leader>tb` | `mvnw`/`mvn` compile or `gradlew` classes |
| Verify / check | `<leader>tc` | `mvn verify` or `gradle check` |
| Run app (heuristic) | `<leader>tr` | `gradlew run`, `mvnw spring-boot:run` if the POM looks like Spring, else package |
| Test (neotest) | `<leader>tt` / `<leader>ta` | Nearest / all (neotest-java) |
| JUnit (jdtls) | `<leader>df` / `<leader>dn` | Run test class / nearest method (needs bundles + jdtls) |
| DAP | `<leader>db` / `<leader>dc` / … | Breakpoint, continue, step, UI (`nvim-dap` + jdtls) |
| File type | `<leader>ftj` / `ftm` / `ftt` / `fty` | Force `java` / markdown / toml / yaml filetype |
| Git / UI | `<leader>g*` / `<leader>ub` / `<leader>ut` / `<leader>uh` | Unchanged; see cheatsheet |

## Git worktree

Same shortcuts as before (`<leader>gws`, etc.). See the cheatsheet for the full list.

## Git shortcuts (unchanged)

Telescope, fetch/pull/push, stash, hunk actions, and worktree workflow — all described in `JAVA_NEOVIM_CHEATSHEET.md`.
