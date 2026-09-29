#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Fetching submodules..."
git -C "$DOTFILES_DIR" submodule update --init --recursive

echo "==> Installing packages..."
"$DOTFILES_DIR/install-packages"

echo "==> Stowing configs..."
"$DOTFILES_DIR/install"

echo "Bootstrap complete."
