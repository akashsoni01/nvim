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

## New machine: JDK + scripts

Run the script for your OS **before** relying on jdtls (or install any **JDK 17+** yourself and ensure `java` / `javac` and often **`JAVA_HOME`** are set). These only handle the **JVM on the system**; Neovim still needs **Mason** packages (see below).

| OS | Command |
| --- | --- |
| macOS | `bash ./scripts/setup-java-macos.sh` |
| Linux | `bash ./scripts/setup-java-linux.sh` |
| Termux | `bash ./scripts/setup-java-termux.sh` |

The old `install-debug-adapter-*.sh` names still exist and **forward** to the `setup-java-*.sh` scripts (this config used to install LLDB for native debugging; **Java DAP uses Mason**, not those shims).

## Start a new Java project (plain Maven or Gradle)

### Maven (quickstart archetype)

Run this from a folder where the new project directory should be created (the archetype will create a subdirectory named `demo` here):

```bash
mvn -B archetype:generate \
  -DarchetypeGroupId=org.apache.maven.archetypes \
  -DarchetypeArtifactId=maven-archetype-quickstart \
  -DarchetypeVersion=1.4 \
  -DgroupId=com.example \
  -DartifactId=demo \
  -Dversion=1.0-SNAPSHOT \
  -Dpackage=com.example
cd demo
nvim src/main/java/com/example/App.java
```

Change `groupId`, `artifactId`, and `package` to match your org. To add the **Maven Wrapper** later, see the [Apache Maven Wrapper](https://maven.apache.org/wrapper/) docs, then commit `mvnw` and `.mvn/`.

### Gradle

In an empty directory:

```bash
gradle init --type java-application
# or: gradle init   # and pick "application" / Java when prompted
nvim .
```

Open the generated `src/main/java/...` entry class. Prefer including **`gradlew`** in the repo (`gradle wrapper`) so CI and teammates use the same Gradle version.

## Start a new Spring Boot project

### Option A — [start.spring.io](https://start.spring.io) (easiest)

Choose **Maven** or **Gradle**, **Java** version, **Spring Boot** version, and dependencies (e.g. **Spring Web**). Click **Generate**, unzip, then:

```bash
cd your-project
./mvnw -q -DskipTests compile   # or ./gradlew classes
nvim .
```

Open the `*Application.java` class under `src/main/java/...`.

### Option B — `curl` (Maven zip)

```bash
mkdir spring-demo && cd spring-demo
curl -L "https://start.spring.io/starter.zip" \
  -d type=maven-project \
  -d language=java \
  -d name=demo \
  -d groupId=com.example \
  -d artifactId=demo \
  -d javaVersion=17 \
  -d dependencies=web,actuator \
  -o starter.zip
unzip -q starter.zip && rm starter.zip
chmod +x mvnw 2>/dev/null || true
./mvnw -q -DskipTests compile
nvim .
```

Tweak `javaVersion`, `dependencies`, `artifactId`, etc. The main class path matches your `groupId` / `artifactId` (e.g. `com/example/demo/DemoApplication.java`).

### Option C — Spring Boot CLI

If you use the official CLI: `spring init --dependencies=web my-app && cd my-app` (see [Spring Boot CLI](https://docs.spring.io/spring-boot/docs/current/reference/html/cli.html)).

Run the app from a terminal with **`./mvnw spring-boot:run`** or **`./gradlew bootRun`**, or use **`<leader>tr`** in Neovim when this config detects Spring in `pom.xml` / Gradle.

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
- `bash ./scripts/uninstall-deps.sh` — removes **legacy** codelldb/lldb-dap shims under this repo’s `bin/` (optional; **Java DAP** comes from **Mason**). Read the script help for optionally resetting Mason’s install tree

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
