#!/usr/bin/env bash
# Drive nvim/test/verify.lua headlessly, capture structured result.
# Exits 0 iff status == "ok".
set -uo pipefail

NVIM_CONFIG_DIR="${NVIM_CONFIG_DIR:-$HOME/.config/nvim}"
HARNESS="$NVIM_CONFIG_DIR/test/verify.lua"

if [[ ! -r "$HARNESS" ]]; then
  echo "loop: cannot read $HARNESS" >&2
  exit 2
fi

# `2>&1` so the JSON line lands on stdout where we can grep it.
output="$(nvim --headless -u "$NVIM_CONFIG_DIR/init.lua" \
  +"source $HARNESS" \
  +'qa!' 2>&1 || true)"

# Pull the JSON line; fall back to a synthetic failure if missing.
json="$(printf '%s\n' "$output" | grep -E '^VERIFY_JSON:' | tail -1 || true)"

if [[ -z "$json" ]]; then
  echo "loop: FAIL (no VERIFY_JSON line emitted — harness crashed before reporting)" >&2
  echo "--- raw output ---" >&2
  printf '%s\n' "$output" | head -40 >&2
  exit 1
fi

# Strip the prefix and let `jq` validate the payload.
payload="${json#VERIFY_JSON: }"
status="$(printf '%s' "$payload" | jq -r '.status')"
fails="$(printf '%s' "$payload" | jq -r '.failures | length')"

if [[ "$status" == "ok" ]]; then
  plugins="$(printf '%s' "$payload" | jq -r '.plugins')"
  loaded="$(printf '%s' "$payload" | jq -r '.loaded')"
  echo "loop: OK ($plugins plugins, $loaded loaded, 0 errors)"
  exit 0
fi

echo "loop: FAIL ($fails error(s))"
printf '%s' "$payload" | jq -r '.failures[]' | sed 's/^/  /'
exit 1
