#!/usr/bin/env bash
set -euo pipefail

# Create symlinks from this repo's canonical skills/ and agents/ trees into
# tool-specific homes. By default this is a dry run. Pass --apply to write.
#
# Claude target:   ~/.claude/{skills,agents}
# Codex target:    ~/.codex/skills/    (skills only; Codex packaging uses skills/plugins)
# Gemini target:   ~/.gemini/skills/   (skills only; Gemini has no agents dir)
# Neutral target:  ${XDG_CONFIG_HOME:-~/.config}/agent-bundles/{skills,agents}
#
# The neutral target is a repo convention, not an official cross-vendor spec.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

CLAUDE_HOME="${HOME}/.claude"
CODEX_HOME="${HOME}/.codex"
GEMINI_HOME="${HOME}/.gemini"
NEUTRAL_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}/agent-bundles"

APPLY=0
FORCE=0
INCLUDE_CLAUDE=1
INCLUDE_CODEX=1
INCLUDE_GEMINI=1
INCLUDE_NEUTRAL=1
CODEX_SKILLS=(
  cli-jesus
  conventional-commits
  git-context-recovery
  python-class-design
  reduce-hallucinations
  round
  terminal-tool-bootstrap
)

usage() {
  cat <<'EOF'
Usage: scripts/link-agent-assets.sh [--apply] [--force] [--claude-only] [--codex-only] [--gemini-only] [--neutral-only] [--no-codex] [--no-gemini]

Defaults to dry-run output. Use --apply to create symlinks.
Use --force to replace existing real directories with symlinks (backs up originals).

Targets (fixed defaults):
  Claude:   ~/.claude/{skills,agents}
  Codex:    ~/.codex/skills/ (curated Codex-ready subset only)
  Gemini:   ~/.gemini/skills/
  Neutral:  ${XDG_CONFIG_HOME:-~/.config}/agent-bundles/{skills,agents}
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

  run_or_print mkdir -p "$(dirname "${target_path}")"
  run_or_print ln -sfn "${source_path}" "${target_path}"
}

link_tree_children() {
  local source_root="$1"
  local target_root="$2"

  if [[ ! -d "${source_root}" ]]; then
    log "SKIP missing source root: ${source_root}"
    return 0
  fi

  run_or_print mkdir -p "${target_root}"

  local child
  while IFS= read -r -d '' child; do
    local name
    name="$(basename "${child}")"
    [[ "${name}" == .* ]] && continue   # skip dotfiles / .DS_Store etc.
    link_item "${child}" "${target_root}/${name}"
  done < <(find "${source_root}" -mindepth 1 -maxdepth 1 -print0 | sort -z)
}

link_named_children() {
  local source_root="$1"
  local target_root="$2"
  shift 2

  if [[ ! -d "${source_root}" ]]; then
    log "SKIP missing source root: ${source_root}"
    return 0
  fi

  run_or_print mkdir -p "${target_root}"

  local name
  for name in "$@"; do
    local child="${source_root}/${name}"
    if [[ ! -e "${child}" ]]; then
      log "SKIP missing source item: ${child}"
      continue
    fi
    link_item "${child}" "${target_root}/${name}"
  done
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
    --claude-only)
      INCLUDE_CODEX=0
      INCLUDE_GEMINI=0
      INCLUDE_NEUTRAL=0
      shift
      ;;
    --codex-only)
      INCLUDE_CLAUDE=0
      INCLUDE_GEMINI=0
      INCLUDE_NEUTRAL=0
      shift
      ;;
    --gemini-only)
      INCLUDE_CLAUDE=0
      INCLUDE_CODEX=0
      INCLUDE_NEUTRAL=0
      shift
      ;;
    --neutral-only)
      INCLUDE_CLAUDE=0
      INCLUDE_CODEX=0
      INCLUDE_GEMINI=0
      shift
      ;;
    --no-codex)
      INCLUDE_CODEX=0
      shift
      ;;
    --no-gemini)
      INCLUDE_GEMINI=0
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

if [[ "${INCLUDE_CLAUDE}" -eq 1 ]]; then
  log "Target: ${CLAUDE_HOME}"
  link_tree_children "${REPO_ROOT}/skills" "${CLAUDE_HOME}/skills"
  link_tree_children "${REPO_ROOT}/agents" "${CLAUDE_HOME}/agents"
fi

if [[ "${INCLUDE_CODEX}" -eq 1 ]]; then
  log "Target: ${CODEX_HOME} (skills only; curated Codex-ready subset)"
  link_named_children "${REPO_ROOT}/skills" "${CODEX_HOME}/skills" "${CODEX_SKILLS[@]}"
fi

if [[ "${INCLUDE_GEMINI}" -eq 1 ]]; then
  log "Target: ${GEMINI_HOME} (skills only)"
  link_tree_children "${REPO_ROOT}/skills" "${GEMINI_HOME}/skills"
fi

if [[ "${INCLUDE_NEUTRAL}" -eq 1 ]]; then
  log "Target: ${NEUTRAL_HOME}"
  link_tree_children "${REPO_ROOT}/skills" "${NEUTRAL_HOME}/skills"
  link_tree_children "${REPO_ROOT}/agents" "${NEUTRAL_HOME}/agents"
fi
