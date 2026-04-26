# Java + Neovim Cheatsheet

**New / Spring Boot projects** — see [README.md](./README.md) (“New machine: JDK + scripts”, “Start a new Java project”, “Start a new Spring Boot project”).

## Leader

- `Leader` = `Space`

## All shortcuts (summary)

| Area | Shortcut | Action |
| --- | --- | --- |
| Telescope | `<leader>ff` | Find files |
| Telescope | `<leader>fg` | Live grep |
| Telescope | `<leader>fb` | Buffers |
| Telescope | `<leader>fh` | Help tags |
| LSP | `gd` / `gr` / `K` / `<C-k>` | Definition / references / hover / signature |
| LSP | `<leader>ca` / `<leader>rn` / `<leader>fm` | Code action / rename / format |
| jdtls | `<leader>oi` | Organize imports |
| jdtls tests | `<leader>df` | Run current JUnit class (DAP; needs bundles) |
| jdtls tests | `<leader>dn` | Run nearest test method (DAP) |
| Neotest | `<leader>tt` | Nearest test |
| Neotest | `<leader>ta` | All tests in scope |
| Neotest | `<leader>to` / `<leader>ts` | Output / summary |
| Build | `<leader>tb` | Compile (Maven/Gradle, `-DskipTests` where used) |
| Build | `<leader>tc` | `mvn verify` / `gradle check` |
| Build | `<leader>tr` | Run app: Gradle `run`, or Spring `spring-boot:run`, or `mvn package` |
| DAP | `<leader>db` | Toggle breakpoint |
| DAP | `<leader>dc` | Continue / start (pick `java` config) |
| DAP | `<leader>do` / `<leader>di` / `<leader>dO` | Step over / into / out |
| DAP | `<leader>du` / `<leader>de` / `<leader>dx` / `<leader>dr` | UI / eval / terminate / REPL |
| File type | `<leader>ftj` / `ftm` / `ftt` / `fty` | `java` / `markdown` / `toml` / `yaml` |
| Git / window / theme | `<leader>g*`, `<leader>s*`, `<leader>q*`, `<leader>u*`, `<leader>t*`, `<leader>th`/`tv` | See README |

## LSP and jdtls

- jdtls starts when you open a **`.java`** file in a project with Maven or Gradle (see [nvim-jdtls](https://codeberg.org/mfussenegger/nvim-jdtls) troubleshooting if nothing starts).
- Useful commands: `:JdtCompile`, `:JdtUpdateConfig`, `:JdtUpdateDebugConfig` / `:JdtRefreshDebugConfigs`, `:JdtSetRuntime`, `:JdtShowLogs`.
- Install **JDK**; eclipse.jdt.ls is often run with a **newer** JVM than your app — configure `java.configuration.runtimes` in `lua/config/jdtls.lua` if you need e.g. Java 11/17/21 for code vs server.

## Debugging (DAP + Java)

1. In **`:Mason`**, install **jdtls**, **java-debug-adapter**, **java-test** (bundles are wired in `lua/config/jdtls.lua`).
2. Open a Java file so jdtls attaches; wait for the project to import.
3. If needed, run **`:JdtUpdateDebugConfig`** (or the refresh command your jdtls build exposes) so `dap.configurations.java` is populated.
4. **`<leader>dc`**, choose a launch or test config; set breakpoints with **`<leader>db`**, toggle UI with **`<leader>du`**.
5. Optional remote: configs include **attach to port 5005** in `lua/plugins/init.lua` (`nvim-dap`).

## Neotest (neotest-java)

- One-time: **`:NeotestJava setup`** to fetch the JUnit platform JAR.
- **`<leader>tt`** (nearest) and **`<leader>ta`** (suite) use the adapter; output/summary: **`<leader>to`**, **`<leader>ts`**.
- DAP while testing is supported by the plugin; see [rcasia/neotest-java](https://github.com/rcasia/neotest-java).

## Build shortcuts (`<leader>tb` / `tc` / `tr`)

- Detection uses **`mvnw`**, **`pom.xml`**, **`gradlew`**, and **`build.gradle*`** in the current working directory (run from the **project root** or `cd` there first).
- **`<leader>tr`**: `gradlew run` for Gradle; if the `pom.xml` contains Spring Boot coordinates, `mvnw spring-boot:run` is used; otherwise a packaging build may run — adjust locally if you use a different entrypoint.

## File types

- **`<leader>ftj`**: set filetype to **java** (e.g. after temporarily switching with `ftm`).
- `ftm` / `ftt` / `fty`: markdown / toml / yaml for config and docs.

## Git (unchanged)

- Status / log / branches / diffs, fetch / pull / push, stash, hunks, worktrees: same as before (`<leader>gs`, `<leader>gco`, `<leader>gws`, etc.).

## Health checks

- `:checkhealth`  
- `nvim` + LSP: `:LspInfo` (should show jdtls on a `*.java` buffer)  
- Mason: `:Mason`  
- Neotest: `:checkhealth neotest` and `:checkhealth neotest-java` if available  
