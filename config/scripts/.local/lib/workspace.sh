#!/usr/bin/env bash
# Shared workspace context detection for wt and config.
# Source this file; it exports WORKSPACE_ROOT, BASE_REPO_PATH, LOCAL_DIR.

WORKSPACE_ROOT=""
BASE_REPO_PATH=""
LOCAL_DIR=""

info() { echo -e "ℹ️  $*" >&2; }
success() { echo -e "✅ $*" >&2; }
warn() { echo -e "⚠️  $*" >&2; }
die() {
  echo -e "❌ Error: $*" >&2
  exit 1
}

# Detect workspace root, base repo, and -local repo.
# Works from: inside any worktree, the main repo, the -local repo,
# or one level above (the parent/workspace directory).
setup_context() {
  local git_root current_dir_name common_dir

  if git_root="$(git rev-parse --show-toplevel 2>/dev/null)"; then
    current_dir_name="$(basename "$git_root")"

    if [[ "$current_dir_name" == *-local ]]; then
      WORKSPACE_ROOT="$(dirname "$git_root")"
      BASE_REPO_PATH="$WORKSPACE_ROOT/${current_dir_name%-local}"

      if [[ ! -d "$BASE_REPO_PATH" ]]; then
        die "Target repository not found at $BASE_REPO_PATH"
      fi
    else
      common_dir="$(git -C "$git_root" rev-parse --git-common-dir)"
      BASE_REPO_PATH="$(cd "$git_root" && cd "$common_dir/.." && pwd)"
      WORKSPACE_ROOT="$(dirname "$BASE_REPO_PATH")"
    fi
  else
    local local_dirs=()
    for d in "$PWD"/*-local; do
      [[ -d "$d/.git" ]] && local_dirs+=("$d")
    done

    if [[ ${#local_dirs[@]} -eq 0 ]]; then
      die "Cannot determine workspace. Run from inside a repo or its parent directory."
    elif [[ ${#local_dirs[@]} -gt 1 ]]; then
      die "Multiple -local repos found. Please run from inside a specific repo."
    fi

    local base_name
    base_name="$(basename "${local_dirs[0]}")"
    WORKSPACE_ROOT="$PWD"
    BASE_REPO_PATH="$WORKSPACE_ROOT/${base_name%-local}"

    if [[ ! -d "$BASE_REPO_PATH" ]]; then
      die "Base repository not found at $BASE_REPO_PATH"
    fi
  fi

  LOCAL_DIR="$WORKSPACE_ROOT/$(basename "$BASE_REPO_PATH")-local"
}
