#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: tmux-dev-layout.sh [options]

Create or attach to a three-pane tmux development layout:

  ┌──────────────────────┬──────────┐
  │                      │ server   │
  │   main               │          │
  │                      ├──────────┤
  │                      │ client   │
  └──────────────────────┴──────────┘

Options:
  --session NAME       Session name. Defaults to the basename of --root.
  --root PATH          Working directory for all panes. Defaults to $PWD.
  --server-cmd CMD     Command to run in the top-right pane.
  --client-cmd CMD     Command to run in the bottom-right pane.
  --right-width PCT    Width of the right column. Default: 30
  --top-height PCT     Height of the top-right pane. Default: 50
  --no-attach          Create or update the session without attaching.
  -h, --help           Show this help.

Examples:
  scripts/tmux-dev-layout.sh
  scripts/tmux-dev-layout.sh --session ccconfig --server-cmd "uv run api"
  scripts/tmux-dev-layout.sh --root ~/proj/app --server-cmd "cd backend && ./run.sh" --client-cmd "./run.sh"
EOF
}

require_tmux() {
  if ! command -v tmux >/dev/null 2>&1; then
    echo "Error: tmux is not installed or not on PATH." >&2
    exit 1
  fi
}

attach_or_switch() {
  local session="$1"

  if [[ "${NO_ATTACH}" == "1" ]]; then
    return 0
  fi

  if [[ -n "${TMUX:-}" ]]; then
    tmux switch-client -t "${session}"
  else
    tmux attach-session -t "${session}"
  fi
}

ROOT="$PWD"
SESSION=""
SERVER_CMD=""
CLIENT_CMD=""
RIGHT_WIDTH="30"
TOP_HEIGHT="50"
NO_ATTACH="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --session)
      SESSION="${2:?missing value for --session}"
      shift 2
      ;;
    --root)
      ROOT="${2:?missing value for --root}"
      shift 2
      ;;
    --server-cmd)
      SERVER_CMD="${2:?missing value for --server-cmd}"
      shift 2
      ;;
    --client-cmd)
      CLIENT_CMD="${2:?missing value for --client-cmd}"
      shift 2
      ;;
    --right-width)
      RIGHT_WIDTH="${2:?missing value for --right-width}"
      shift 2
      ;;
    --top-height)
      TOP_HEIGHT="${2:?missing value for --top-height}"
      shift 2
      ;;
    --no-attach)
      NO_ATTACH="1"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

require_tmux

if [[ ! -d "${ROOT}" ]]; then
  echo "Error: root directory does not exist: ${ROOT}" >&2
  exit 1
fi

if [[ -z "${SESSION}" ]]; then
  SESSION="$(basename "${ROOT}")"
fi

if ! [[ "${RIGHT_WIDTH}" =~ ^[0-9]+$ ]] || (( RIGHT_WIDTH < 10 || RIGHT_WIDTH > 90 )); then
  echo "Error: --right-width must be an integer between 10 and 90." >&2
  exit 1
fi

if ! [[ "${TOP_HEIGHT}" =~ ^[0-9]+$ ]] || (( TOP_HEIGHT < 10 || TOP_HEIGHT > 90 )); then
  echo "Error: --top-height must be an integer between 10 and 90." >&2
  exit 1
fi

if tmux has-session -t "${SESSION}" 2>/dev/null; then
  echo "Session '${SESSION}' already exists."
  attach_or_switch "${SESSION}"
  exit 0
fi

tmux new-session -d -s "${SESSION}" -c "${ROOT}"
tmux split-window -h -p "${RIGHT_WIDTH}" -t "${SESSION}:0" -c "${ROOT}"
tmux split-window -v -p $((100 - TOP_HEIGHT)) -t "${SESSION}:0.1" -c "${ROOT}"

tmux select-pane -t "${SESSION}:0.0" -T main
tmux select-pane -t "${SESSION}:0.1" -T server
tmux select-pane -t "${SESSION}:0.2" -T client

if [[ -n "${SERVER_CMD}" ]]; then
  tmux send-keys -t "${SESSION}:0.1" "${SERVER_CMD}" C-m
fi

if [[ -n "${CLIENT_CMD}" ]]; then
  tmux send-keys -t "${SESSION}:0.2" "${CLIENT_CMD}" C-m
fi

tmux select-pane -t "${SESSION}:0.0"
attach_or_switch "${SESSION}"
