#!/usr/bin/env bash
set -euo pipefail

# ── Paths ─────────────────────────────────────────────
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$ROOT_DIR/logs/script_logs.txt"

# ── Ensure dirs ───────────────────────────────────────
mkdir -p "$ROOT_DIR/logs" "$ROOT_DIR/backups"

# ── Colors (fallback if not TTY) ──────────────────────
if [[ -t 1 ]]; then
  BOLD="$(tput bold)"; DIM="$(tput dim)"; RESET="$(tput sgr0)"
  RED="$(tput setaf 1)"; GREEN="$(tput setaf 2)"; YELLOW="$(tput setaf 3)"; BLUE="$(tput setaf 4)"
else
  BOLD=""; DIM=""; RESET=""; RED=""; GREEN=""; YELLOW=""; BLUE=""
fi

# ── Helpers ───────────────────────────────────────────
pause(){ read -rp "Press Enter to continue..." _; }
run_or_warn(){
  local file="$1"
  if [[ -x "$file" ]]; then
    bash "$file"
  else
    printf "%s[WARN]%s Script not found or not executable: %s\n" "$YELLOW" "$RESET" "$file"
    pause
  fi
}

# ── Actions ───────────────────────────────────────────
do_backup(){      run_or_warn "$SCRIPT_DIR/backup.sh"; pause; }
do_maint(){       run_or_warn "$SCRIPT_DIR/update_cleanup.sh"; pause; }
do_monitor(){
  echo "Launching log monitor (Ctrl+C to stop)..."
  run_or_warn "$SCRIPT_DIR/log_monitor.sh"
}
do_view_logs(){   ${PAGER:-less} "$LOG_FILE"; }

# ── Cleanup on Ctrl+C ─────────────────────────────────
trap 'echo; printf "%s[INFO]%s Interrupted. Returning to menu.\n" "$YELLOW" "$RESET"' INT

# ── Menu Loop ─────────────────────────────────────────
while true; do
  clear
  printf "%sSystem Maintenance Suite%s  %s%s%s\n" "$BOLD" "$RESET" "$DIM" "$(date)" "$RESET"
  printf "%s============================================================%s\n" "$BLUE" "$RESET"
  printf "  1) Run Backup\n"
  printf "  2) System Update & Cleanup\n"
  printf "  3) Live Log Monitor\n"
  printf "  4) View Suite Logs\n"
  printf "  5) Exit\n"
  printf "%s============================================================%s\n" "$BLUE" "$RESET"

  read -rp "Choose an option [1-5]: " opt
  case "${opt//[[:space:]]/}" in
    1) do_backup ;;
    2) do_maint ;;
    3) do_monitor ;;
    4) do_view_logs ;;
    5) printf "%s[OK]%s Goodbye!\n" "$GREEN" "$RESET"; exit 0 ;;
    *) printf "%s[ERR]%s Invalid option. Try 1-5.\n" "$RED" "$RESET"; sleep 1 ;;
  esac
done
