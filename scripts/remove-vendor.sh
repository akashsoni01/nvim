#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR_DIR="$ROOT_DIR/vendor"

YES=0
if [[ "${1:-}" == "--yes" || "${1:-}" == "-y" ]]; then
  YES=1
fi

if [[ ! -d "$VENDOR_DIR" ]]; then
  echo "No vendor directory found: $VENDOR_DIR"
  exit 0
fi

echo "This will remove local vendored plugin sources:"
echo "  $VENDOR_DIR"
echo
echo "Neovim will need internet/lazy.nvim data, or you can re-run:"
echo "  bash ./scripts/vendor-plugins.sh"
echo

if [[ "$YES" -ne 1 ]]; then
  read -r -p "Remove vendor directory? [y/N] " answer
  case "$answer" in
    y|Y|yes|YES) ;;
    *)
      echo "Cancelled."
      exit 0
      ;;
  esac
fi

rm -rf -- "$VENDOR_DIR"
echo "Removed: $VENDOR_DIR"
