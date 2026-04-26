#!/usr/bin/env bash
set -euo pipefail

# Installs a JDK from your distro (when possible) for Java + Neovim. Mason supplies jdtls and Java DAP JARs.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./setup-java-common.sh
source "$ROOT/setup-java-common.sh"

if have java && have javac; then
  echo "JDK already on PATH."
  print_done
  exit 0
fi

echo "No full JDK on PATH. Trying the system package manager…"

maybe_sudo() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  elif have sudo; then
    sudo "$@"
  else
    echo "Run as root or install sudo, then: apt install / dnf install / … openjdk-*-jdk"
    print_mason_reminder
    exit 1
  fi
}

if have apt-get; then
  maybe_sudo apt-get update
  # Prefer a recent LTS metapackage if available
  if apt-cache show openjdk-21-jdk &>/dev/null; then
    maybe_sudo apt-get install -y openjdk-21-jdk
  else
    maybe_sudo apt-get install -y openjdk-17-jdk
  fi
elif have dnf; then
  maybe_sudo dnf install -y java-21-openjdk-devel || maybe_sudo dnf install -y java-17-openjdk-devel
elif have pacman; then
  maybe_sudo pacman -Sy --noconfirm jdk-openjdk
elif have zypper; then
  maybe_sudo zypper install -y java-21-openjdk-devel || maybe_sudo zypper install -y java-17-openjdk
else
  echo "No supported package manager. Install a JDK (Temurin, etc.) and put java/javac on PATH."
  print_mason_reminder
  exit 1
fi

print_done
exit 0
