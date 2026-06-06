#!/usr/bin/env bash
set -euo pipefail

CONFIG_DIR="${CONFIG_DIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/nvim}"
NVIM_BIN_CACHE="${NVIM_BIN_CACHE:-${CONFIG_DIR}/.nvim-bin}"
BIN_DIR="${BIN_DIR:-${XDG_BIN_HOME:-${HOME}/.local/bin}}"
WRAPPER_BIN="${WRAPPER_BIN:-${BIN_DIR}/nvim}"

if [[ -n "${NVIM_BIN:-}" && -x "${NVIM_BIN}" ]]; then
  printf '%s' "${NVIM_BIN}"
  exit 0
fi

if [[ -f "$NVIM_BIN_CACHE" ]]; then
  cached="$(tr -d '\r\n' <"$NVIM_BIN_CACHE")"
  if [[ -n "$cached" && -x "$cached" && "$cached" != "$WRAPPER_BIN" ]]; then
    printf '%s' "$cached"
    exit 0
  fi
fi

trimmed_path=""
entry=""
IFS=':'
for entry in $PATH; do
  [[ -z "$entry" ]] && continue
  if [[ "$entry" == "$BIN_DIR" || "$entry" == "${HOME}/.local/bin" ]]; then
    continue
  fi
  if [[ -n "$trimmed_path" ]]; then
    trimmed_path+=":"
  fi
  trimmed_path+="$entry"
done

candidate=""
if [[ -n "$trimmed_path" ]]; then
  candidate="$(PATH="$trimmed_path" command -v nvim 2>/dev/null || true)"
fi
if [[ -n "$candidate" && -x "$candidate" && "$candidate" != "$WRAPPER_BIN" ]]; then
  printf '%s' "$candidate"
  exit 0
fi

search_paths=(
  /opt/homebrew/bin/nvim
  /usr/local/bin/nvim
  /usr/bin/nvim
  /snap/bin/nvim
  "${HOME}/.cargo/bin/nvim"
  "${HOME}/scoop/shims/nvim"
  "${HOME}/scoop/shims/nvim.exe"
)

for candidate in "${search_paths[@]}"; do
  if [[ -x "$candidate" && "$candidate" != "$WRAPPER_BIN" ]]; then
    printf '%s' "$candidate"
    exit 0
  fi
done

echo "nvim: real binary not found" >&2
exit 1
