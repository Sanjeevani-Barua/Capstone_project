
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
CONF_FILE="$ROOT_DIR/config/log_monitor.conf"
LOG_FILE="$ROOT_DIR/logs/script_logs.txt"

# Pick your log files (edit if needed)
WATCH_FILES=(/var/log/auth.log /var/log/syslog)

mkdir -p "$(dirname "$LOG_FILE")"

log(){ printf "[%s] [monitor] %s\n" "$(date '+%F %T')" "$*" | tee -a "$LOG_FILE"; }

# Build grep -E pattern from non-empty, non-comment lines
build_pattern(){
  awk 'NF && $0 !~ /^#/' "$CONF_FILE" | paste -sd'|' -
}

if [[ ! -f "$CONF_FILE" ]]; then
  echo "Config not found: $CONF_FILE" >&2
  exit 1
fi

PATTERN="$(build_pattern)"
if [[ -z "${PATTERN}" ]]; then
  echo "No patterns found in $CONF_FILE" >&2
  exit 1
fi

log "Monitoring started."
log "Press Ctrl+C to stop."

# Optional: email alerts if 'mail' exists and ALERT_EMAIL is set
ALERT_EMAIL="${ALERT_EMAIL:-}"   # export ALERT_EMAIL=user@example.com to enable

tail -Fn0 "${WATCH_FILES[@]}" | \
while read -r line; do
  if grep -Eiq -- "$PATTERN" <<<"$line"; then
    msg="ALERT: $(date '+%F %T') :: $line"
    log "$msg"
    if [[ -n "$ALERT_EMAIL" ]] && command -v mail >/dev/null 2>&1; then
      printf "%s\n" "$msg" | mail -s "Log Monitor Alert" "$ALERT_EMAIL" || true
    fi
  fi
done
