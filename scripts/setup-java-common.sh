# Shared helpers for setup-java-*.sh (sourced, not run directly)
# shellcheck shell=bash

have() { command -v "$1" >/dev/null 2>&1; }

print_java_info() {
  if have java; then
    echo "java: $(command -v java)"
    java -version 2>&1
  else
    echo "java: not on PATH"
  fi
  if have javac; then
    echo "javac: $(command -v javac)"
  else
    echo "javac: not on PATH (install a JDK, not a JRE-only package)"
  fi
}

print_mason_reminder() {
  echo
  echo "Neovim / Mason (do this in Neovim after plugins load):"
  echo "  :Mason  →  install: jdtls, java-debug-adapter, java-test"
  echo "  :TSInstall java xml"
  echo "  :NeotestJava setup   (neotest-java JUnit JAR, once)"
  echo
  echo "Eclipse JDT (jdtls) is often run with JVM 21+; your app can target 8/11/17 via Maven/Gradle and jdtls runtimes if needed."
}

print_done() {
  print_java_info
  print_mason_reminder
}
