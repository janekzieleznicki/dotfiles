#!/usr/bin/env bash
# TUI loop: drive verify.lua, present failures in a menu, jump to source.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOOP="$SCRIPT_DIR/loop.sh"
EDITOR_CMD="${EDITOR:-${VISUAL:-vi}}"

if [[ ! -x "$LOOP" ]]; then
  echo "tui: $LOOP missing or not executable" >&2
  exit 2
fi

# Pick a TUI toolkit; prefer dialog, fall back to whiptail.
if command -v dialog >/dev/null 2>&1; then
  DIALOG="dialog"
elif command -v whiptail >/dev/null 2>&1; then
  DIALOG="whiptail"
else
  echo "tui: install 'dialog' or 'whiptail' (apt-get install dialog)" >&2
  exit 2
fi

# dialog sends output to stderr by default; --stdout redirects to stdout.
# whiptail sends output to stdout by default; --stdout is not supported.
if [[ "$DIALOG" == "dialog" ]]; then
  DIALOG_STDOUT="--stdout"
else
  DIALOG_STDOUT=""
fi

# Cache the last failure list across iterations.
last_failures_file="$(mktemp -t nvim_verify_failures.XXXXXX)"
trap 'rm -f "$last_failures_file"' EXIT

while true; do
  # Run the harness. Capture exit + JSON for menu population.
  out="$("$LOOP" 2>&1)"
  rc=$?

  # Parse failures (one per line, leading spaces stripped).
  printf '%s\n' "$out" | sed -n 's/^  //p' > "$last_failures_file"

  if [[ $rc -eq 0 ]]; then
    if [[ -t 1 ]]; then
      "$DIALOG" ${DIALOG_STDOUT:+--stdout} --title "nvim verify" --msgbox "Clean run.\n\n$out" 12 70
    else
      printf '%s\n' "$out"
    fi
    exit 0
  fi

  # Build menu items: each line becomes "<index> <text>".
  mapfile -t items < "$last_failures_file"
  if [[ ${#items[@]} -eq 0 ]]; then
    items=("(harness reported failure but no parseable lines — see stderr)")
  fi

  menu_args=()
  for i in "${!items[@]}"; do
    # Truncate to fit a 90-col dialog; keep the line verbatim when shorter.
    short="${items[$i]:0:120}"
    menu_args+=( "$((i+1))" "$short" )
  done

  choice=$("$DIALOG" ${DIALOG_STDOUT:+--stdout} --title "nvim verify — $rc" \
    --menu "Pick a failure to inspect (Cancel = re-run)" 20 120 12 \
    "${menu_args[@]}") || rc=0  # Cancel/Esc re-runs the harness.

  case $rc in
    0)  # User picked a failure.
        line="${items[$((choice-1))]}"
        # Best-effort: extract "file:line:" path from the failure line.
        if [[ "$line" =~ (/[^:[:space:]]+\.(lua|vim|scm)):([0-9]+):? ]]; then
          file="${BASH_REMATCH[1]}"
          lnum="${BASH_REMATCH[3]}"
          "$EDITOR_CMD" "+$lnum" "$file" </dev/tty >/dev/tty 2>&1
        else
          # No parseable location — open the harness output in a viewer.
          "$EDITOR_CMD" "$last_failures_file" </dev/tty >/dev/tty 2>&1
        fi
        ;;
    *)  # Cancel/Esc: drop back to the top of the loop and re-run.
        ;;
  esac
done
