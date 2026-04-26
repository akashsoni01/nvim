#!/usr/bin/env bash
set -euo pipefail

# Installs a JDK in Termux for Java development; Mason (inside Neovim) provides jdtls and debugger bundles.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./setup-java-common.sh
source "$ROOT/setup-java-common.sh"

if have java && have javac; then
  echo "JDK already on PATH."
  print_done
  exit 0
fi

if ! command -v pkg &>/dev/null; then
  echo "This script is for Termux (pkg not found)."
  print_mason_reminder
  exit 1
fi

echo "Updating packages and installing OpenJDK (Termux)…"
pkg update -y
pkg install -y openjdk-17 2>/dev/null || pkg install -y openjdk-21

print_done
exit 0
