#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$ROOT_DIR/logs/script_logs.txt"

mkdir -p "$ROOT_DIR/logs" "$ROOT_DIR/backups"

backups(){ bash "$SCRIPT_DIR/backup.sh"; read -rp "Press Enter to continue..."; }
update_cleanup(){ bash "$SCRIPT_DIR/update_cleanup.sh"; read -rp "Press Enter to continue..."; }
monitor(){
  echo "Starting log monitor (Ctrl+C to stop)..."
  bash "$SCRIPT_DIR/log_monitor.sh"
}
view_logs(){ ${PAGER:-less} "$LOG_FILE"; }

while true; do
  clear
  cat <<MENU
================= System Maintenance Suite =================
1) Run Backup
2) Perform System Update & Cleanup
3) Start Log Monitor (live)
4) View Script Logs
5) Exit
============================================================
MENU
  read -rp "Choose an option [1-5]: " opt
  case "$opt" in
    1) backups ;;
    2) update_cleanup ;;
    3) monitor ;;
    4) view_logs ;;
    5) echo "Goodbye!"; exit 0 ;;
    *) echo "Invalid option"; sleep 1 ;;
  esac
done
