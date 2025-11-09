#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$ROOT_DIR/logs/script_logs.txt"

log(){ printf "[%s] [update] %s\n" "$(date '+%F %T')" "$*" | tee -a "$LOG_FILE"; }

mkdir -p "$(dirname "$LOG_FILE")"

# Use apt (Debian/Ubuntu). Switch to dnf/pacman as needed.
log "Starting system update & cleanup"
if command -v sudo >/dev/null 2>&1; then SUDO=sudo; else SUDO=""; fi

$SUDO apt-get update        | tee -a "$LOG_FILE"
$SUDO apt-get -y upgrade    | tee -a "$LOG_FILE"
$SUDO apt-get -y autoremove | tee -a "$LOG_FILE"
$SUDO apt-get -y autoclean  | tee -a "$LOG_FILE"

log "Update & cleanup finished"
