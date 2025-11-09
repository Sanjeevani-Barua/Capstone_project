#!/usr/bin/env bash
set -euo pipefail

# ── Paths ─────────────────────────────────────────────
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$ROOT_DIR/backups"
LOG_FILE="$ROOT_DIR/logs/script_logs.txt"

# ── User Configurable Paths ───────────────────────────
SOURCE_DIRS=("$HOME/Documents" "$HOME/Pictures" "$HOME/Desktop")   # can edit
EXCLUDES=("--exclude=.cache" "--exclude=node_modules")

# ── Create Directories ────────────────────────────────
mkdir -p "$BACKUP_DIR" "$(dirname "$LOG_FILE")"

# ── Generate Filename with Timestamp ──────────────────
TIMESTAMP="$(date +'%Y-%m-%d_%H-%M-%S')"
ARCHIVE="$BACKUP_DIR/backup_${TIMESTAMP}.tar.gz"

# ── Logging Function with Colors ──────────────────────
log() {
  local GREEN='\033[0;32m'
  local NC='\033[0m' # Reset color
  printf "[%s] ${GREEN}%s${NC}\n" "$(date '+%F %T')" "$*" | tee -a "$LOG_FILE"
}

# ── Script Start ──────────────────────────────────────
log "Backup process started..."
log "Saving files to: $ARCHIVE"

if tar -czf "$ARCHIVE" "${EXCLUDES[@]}" "${SOURCE_DIRS[@]}" 2>>"$LOG_FILE"; then
  log "✅ Backup completed successfully."
else
  log "❌ Backup failed! Check log file: $LOG_FILE"
  exit 1
fi

