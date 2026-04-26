-- Shell commands for Maven / Gradle in the current working directory.
local M = {}

function M.shell_compile()
  if vim.fn.filereadable("mvnw") == 1 then
    return "./mvnw -B -DskipTests compile"
  end
  if vim.fn.filereadable("pom.xml") == 1 then
    return "mvn -B -DskipTests compile"
  end
  if vim.fn.filereadable("gradlew") == 1 then
    return "./gradlew classes --quiet"
  end
  if (vim.fn.glob("build.gradle*") or "") ~= "" then
    return "gradle classes --quiet"
  end
  return "mvn -B -DskipTests compile"
end

function M.shell_check()
  if vim.fn.filereadable("mvnw") == 1 then
    return "./mvnw -B verify"
  end
  if vim.fn.filereadable("pom.xml") == 1 then
    return "mvn -B verify"
  end
  if vim.fn.filereadable("gradlew") == 1 then
    return "./gradlew check"
  end
  if (vim.fn.glob("build.gradle*") or "") ~= "" then
    return "gradle check"
  end
  return "mvn -B verify"
end

function M.shell_test_terminal()
  if vim.fn.filereadable("mvnw") == 1 then
    return "./mvnw -B test"
  end
  if vim.fn.filereadable("pom.xml") == 1 then
    return "mvn -B test"
  end
  if vim.fn.filereadable("gradlew") == 1 then
    return "./gradlew test"
  end
  if (vim.fn.glob("build.gradle*") or "") ~= "" then
    return "gradle test"
  end
  return "mvn -B test"
end

--- Run the application when tooling can infer a reasonable default.
function M.shell_run()
  if vim.fn.filereadable("gradlew") == 1 then
    return "./gradlew run"
  end
  if vim.fn.filereadable("pom.xml") == 1 then
    local content = table.concat(vim.fn.readfile("pom.xml") or {}, "\n")
    if content:find("spring%-boot", 1) or content:find("spring.boot", 1) then
      if vim.fn.filereadable("mvnw") == 1 then
        return "./mvnw spring-boot:run"
      end
      return "mvn spring-boot:run"
    end
  end
  if vim.fn.filereadable("mvnw") == 1 then
    return "./mvnw -B -DskipTests package"
  end
  if vim.fn.filereadable("pom.xml") == 1 then
    return "mvn -B -DskipTests package"
  end
  return "echo 'Add a Maven/Gradle build or use <leader>dc (DAP) to run' && " .. (vim.env.SHELL or "bash")
end

return M
