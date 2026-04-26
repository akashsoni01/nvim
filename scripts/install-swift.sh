#!/usr/bin/env bash
# Install the Swift compiler toolchain (swift, swift package, sourcekit-lsp) for Neovim Swift development.
# Supports: macOS, Linux (Swiftly + distro packages), FreeBSD, Termux.
# Official docs: https://www.swift.org/install/
set -euo pipefail

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" || "${1:-}" == "-n" ]]; then
  DRY_RUN=1
fi
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  echo "Usage: $0 [--dry-run]"
  echo "Installs Swift when missing. Re-run is safe: exits early if \`swift\` is on PATH."
  echo "https://www.swift.org/install/"
  exit 0
fi

have() { command -v "$1" >/dev/null 2>&1; }

maybe_sudo() {
  if [[ "$(id -u)" -eq 0 ]]; then
    "$@"
  else
    if ! have sudo; then
      echo "Need sudo to install system packages, or run as root."
      exit 1
    fi
    sudo "$@"
  fi
}

if have swift; then
  echo "Swift already on PATH: $(command -v swift)"
  swift --version
  exit 0
fi

echo "Swift not found. Detecting OS..."

# --- macOS: Homebrew, then Command Line Tools hint ---
if [[ "$(uname -s)" == "Darwin" ]]; then
  if have brew; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "Would run: brew install swift"
      exit 0
    fi
    echo "Installing Swift via Homebrew..."
    brew install swift
    if have swift; then
      swift --version
      exit 0
    fi
    echo "Homebrew install finished but \`swift\` not found on PATH. Try: rehash, or: brew list swift"
    exit 1
  else
    if xcode-select -p &>/dev/null; then
      if [[ -x /usr/bin/swift ]]; then
        echo "Xcode/CLT present; /usr/bin/swift should be available. Check PATH."
        /usr/bin/swift --version || true
        exit 0
      fi
    fi
    echo "On macOS, install one of:"
    echo "  - Xcode from the App Store, or"
    echo "  - Command Line Tools:  xcode-select --install"
    echo "  - Or Homebrew:         brew install swift"
    echo "See https://www.swift.org/install/macos/"
    exit 1
  fi
fi

# --- Termux (Android) ---
if [[ -n "${PREFIX:-}" && "${PREFIX}" == *com.termux* ]] && have pkg; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "Would run: pkg install swift"
    exit 0
  fi
  echo "Termux: installing Swift via pkg (if available)..."
  pkg update -y
  if pkg install -y swift; then
    command -v swift
    swift --version
    exit 0
  fi
  echo "Package 'swift' may be unavailable in your Termux repo. Try:"
  echo "  https://github.com/termux/termux-packages  (search: swift)"
  echo "  Or use Swift in proot/Linux chroot on device."
  exit 1
fi

# --- FreeBSD ---
if [[ "$(uname -s)" == "FreeBSD" ]]; then
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "Would run: pkg install -y swift"
    exit 0
  fi
  if have pkg; then
    maybe_sudo env ASSUME_ALWAYS_YES=yes pkg install -y swift
  fi
  if have swift; then
    swift --version
    exit 0
  fi
  echo "See https://www.swift.org/download/ (FreeBSD / source builds)."
  exit 1
fi

# --- Linux & others (WSL2 counts as Linux) ---
if [[ "$(uname -s)" != "Linux" ]]; then
  echo "Unsupported uname: $(uname -s). See https://www.swift.org/install/"
  exit 1
fi

if [[ -r /etc/os-release ]]; then
  # shellcheck source=/dev/null
  . /etc/os-release
  if [[ "${ID:-}" == "alpine" ]]; then
    echo "Note: Alpine (musl) has no first-class official Swift build; use a glibc-based distro, Docker,"
    echo "or build from source. See https://www.swift.org/install/"
  fi
fi

# Distro quick installs where the package is known to be Apple's Swift (not OpenStack "swift" on old Ubuntu)
linux_try_distro_package() {
  if have apt-get; then
    if [[ -r /etc/os-release ]]; then
      # shellcheck source=/dev/null
      . /etc/os-release
      if [[ "${ID:-}" == "debian" || "${ID:-}" == "ubuntu" || "${ID_LIKE:-}" == *debian* ]]; then
        local v="${VERSION_ID:-0}"
        v="${v%%.*}"
        if [[ "$v" =~ ^[0-9]+$ ]] && [[ "$v" -ge 26 ]]; then
          if [[ "$DRY_RUN" -eq 1 ]]; then
            echo "Would run: apt install swiftlang (Debian family, VERSION_ID>=26)"
            return 1
          fi
          echo "Trying apt install swiftlang (Ubuntu/Debian 26+)..."
          maybe_sudo apt-get update -y
          if maybe_sudo apt-get install -y swiftlang; then
            have swift && return 0
          fi
        fi
      fi
    fi
  fi
  if have dnf; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "Would run: dnf install -y swift-lang (or swift)"
      return 1
    fi
    echo "Trying dnf install swift / swift-lang (Fedora/RHEL)..."
    maybe_sudo dnf install -y swift-lang 2>/dev/null || maybe_sudo dnf install -y swift 2>/dev/null || true
    have swift && return 0
  fi
  if have pacman; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "Would run: pacman -S --noconfirm swift"
      return 1
    fi
    echo "Trying pacman -S swift (Arch Linux)..."
    maybe_sudo pacman -S --noconfirm swift || true
    have swift && return 0
  fi
  if have zypper; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "Would run: zypper install -y swift"
      return 1
    fi
    echo "Trying zypper (openSUSE)..."
    maybe_sudo zypper install -y swift 2>/dev/null || true
    have swift && return 0
  fi
  return 1
}

if linux_try_distro_package; then
  echo "Installed via package manager: $(command -v swift)"
  swift --version
  exit 0
fi

# --- Linux: official Swiftly (works across many distros) ---
# https://www.swift.org/install/linux/
if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "Would download Swiftly from download.swift.org and run: swiftly init --quiet-shell-followup"
  echo "See: https://www.swift.org/install/linux/"
  exit 0
fi

for need in curl tar; do
  if ! have "$need"; then
    echo "Install $need (and common build deps) then re-run, or use your distro’s Swift packages."
    echo "Example: sudo apt install -y curl ca-certificates tar"
    exit 1
  fi
done

arch="$(uname -m)"
# Swiftly publishes aarch64 and x86_64
if [[ "$arch" != "x86_64" && "$arch" != "aarch64" ]]; then
  echo "No official Swiftly tarball for uname -m=$arch. Try: https://www.swift.org/install/linux/tarball"
  exit 1
fi

URL="https://download.swift.org/swiftly/linux/swiftly-${arch}.tar.gz"
TMP="$(mktemp -d)"
cleanup() { rm -rf "$TMP"; }
trap cleanup EXIT
cd "$TMP"

echo "Downloading Swiftly: $URL"
curl -fL -O "$URL"
tar -xzf "swiftly-${arch}.tar.gz"
if [[ ! -x ./swiftly ]]; then
  echo "Expected ./swiftly binary after extract."
  exit 1
fi

echo "Running Swiftly init (official Swift.org installer)..."
./swiftly init --quiet-shell-followup

SWIFTLY_HOME="${SWIFTLY_HOME_DIR:-$HOME/.local/share/swiftly}"
if [[ -f "$SWIFTLY_HOME/env.sh" ]]; then
  # shellcheck source=/dev/null
  . "$SWIFTLY_HOME/env.sh"
  hash -r
fi

if ! have swift; then
  echo "swift still not on PATH. Add to your shell config:"
  echo "  source $SWIFTLY_HOME/env.sh"
  echo "Then run:  hash -r && swift --version"
  echo "If Swiftly reported missing system libraries, run the apt/dnf line it printed."
  exit 1
fi

echo "Success: $(command -v swift)"
swift --version
echo
echo "Add this to ~/.bashrc or ~/.zshrc if new shells do not see swift:"
echo "  [[ -f $SWIFTLY_HOME/env.sh ]] && source $SWIFTLY_HOME/env.sh"
exit 0
