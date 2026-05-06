#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
USER_BIN_DIR="${HOME}/.local/bin"

APPLY=0
FORCE=0

ITEMS=(
  plz
)

usage() {
  cat <<'EOF'
Usage: scripts/link-user-bin.sh [--apply] [--force]

Defaults to dry-run output. Use --apply to create symlinks in ~/.local/bin.
Use --force to replace existing non-symlink files or directories with symlinks
after backing them up.
EOF
}

log() {
  printf '%s\n' "$*"
}

run_or_print() {
  if [[ "${APPLY}" -eq 1 ]]; then
    "$@"
  else
    printf 'DRY-RUN:'
    for arg in "$@"; do
      printf ' %q' "${arg}"
    done
    printf '\n'
  fi
}

link_item() {
  local source_path="$1"
  local target_path="$2"

  if [[ -L "${target_path}" ]]; then
    local current_target
    current_target="$(readlink "${target_path}")"
    if [[ "${current_target}" == "${source_path}" ]]; then
      log "OK ${target_path} -> ${source_path}"
      return 0
    fi
  fi

  if [[ -e "${target_path}" && ! -L "${target_path}" ]]; then
    if [[ "${FORCE}" -eq 0 ]]; then
      log "SKIP existing non-symlink (use --force to replace): ${target_path}"
      return 0
    fi
    local backup_path="${target_path}.bak.$(date +%Y%m%d_%H%M%S)"
    log "BACKUP ${target_path} -> ${backup_path}"
    run_or_print mv "${target_path}" "${backup_path}"
  fi

  run_or_print mkdir -p "${USER_BIN_DIR}"
  run_or_print ln -sfn "${source_path}" "${target_path}"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply)
      APPLY=1
      shift
      ;;
    --force)
      FORCE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

log "Target: ${USER_BIN_DIR}"
for name in "${ITEMS[@]}"; do
  source_path="${REPO_ROOT}/scripts/${name}"
  target_path="${USER_BIN_DIR}/${name}"
  if [[ ! -f "${source_path}" ]]; then
    log "SKIP missing source item: ${source_path}"
    continue
  fi
  link_item "${source_path}" "${target_path}"
done
