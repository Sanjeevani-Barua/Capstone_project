#!/usr/bin/env bash
set -euo pipefail


SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$ROOT_DIR/backups"
LOG_FILE="$ROOT_DIR/logs/script_logs.txt"

SOURCE_DIRS=("$HOME/Documents" "$HOME/Pictures" "$HOME/Desktop")   # <-- edit as needed
EXCLUDES=("--exclude=.cache" "--exclude=node_modules")

TIMESTAMP="$(date +'%Y-%m-%d_%H-%M-%S')"
ARCHIVE="$BACKUP_DIR/backup_$TIMESTAMP.tar.gz"
# ------------------------

mkdir -p "$BACKUP_DIR" "$(dirname "$LOG_FILE")"

log(){ printf "[%s] [backup] %s\n" "$(date '+%F %T')" "$*" | tee -a "$LOG_FILE"; }

log "Starting backup to $ARCHIVE"
tar -czf "$ARCHIVE" "${EXCLUDES[@]}" "${SOURCE_DIRS[@]}" 2>>"$LOG_FILE"
log "Backup completed: $ARCHIVE"
