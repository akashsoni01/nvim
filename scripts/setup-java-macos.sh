#!/usr/bin/env bash
set -euo pipefail

# Installs or finds a JDK for Java + Neovim (jdtls) on macOS. Java DAP JARs come from Mason inside Neovim, not this script.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./setup-java-common.sh
source "$ROOT/setup-java-common.sh"

if have java && have javac; then
  echo "JDK already on PATH."
  print_done
  exit 0
fi

echo "No full JDK (java+javac) found on PATH. Trying Homebrew (openjdk)…"
if ! have brew; then
  echo "Install Homebrew from https://brew.sh then re-run, or install a JDK (Temurin, Azul) from a .pkg"
  print_mason_reminder
  exit 1
fi

# Prefer a current LTS; user can switch with brew.
if ! brew list openjdk@21 &>/dev/null; then
  brew install openjdk@21
fi

BREW_PREFIX="$(brew --prefix openjdk@21 2>/dev/null || brew --prefix openjdk@17 2>/dev/null || true)"
if [[ -n "${BREW_PREFIX}" ]]; then
  export PATH="${BREW_PREFIX}/bin:${PATH}"
  if [[ -d "${BREW_PREFIX}/libexec/openjdk.jdk/Contents/Home" ]]; then
    export JAVA_HOME="${BREW_PREFIX}/libexec/openjdk.jdk/Contents/Home"
  fi
  echo
  echo "For new shells, add to ~/.zshrc (or ~/.profile):"
  echo "  export PATH=\"${BREW_PREFIX}/bin:\$PATH\""
  if [[ -n "${JAVA_HOME:-}" ]]; then
    echo "  export JAVA_HOME=\"${JAVA_HOME}\""
  fi
fi

if [[ -x /usr/libexec/java_home ]]; then
  echo
  echo "Or pick an installed JVM with: /usr/libexec/java_home -V"
fi

print_done
exit 0
