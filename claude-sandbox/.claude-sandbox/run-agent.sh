#!/usr/bin/env bash
set -euo pipefail

: "${CS_SESSION_ID:?CS_SESSION_ID required}"

# Passive DNS egress logging in the background.
sudo /usr/local/bin/log-egress.sh "$CS_SESSION_ID" &

# Seed mise-managed toolchains if the worktree pins any.
# First run on a fresh `claude-sandbox-home` volume has an empty shim dir
# (/home/claude/.local/share/mise/shims/), so PATH references it but nothing
# resolves there, and `node`/`yarn`/`ruby` fall through to the base image.
# `mise install` populates the shims and persists them in the volume; trust
# is granted via MISE_TRUSTED_CONFIG_PATHS set by the wrapper.
if [[ -f mise.toml || -f .mise.toml || -f .tool-versions ]]; then
  mise install 2>&1 || echo "[claude-sandbox] mise install failed, continuing" >&2
fi

MODE="${CS_MODE:-interactive}"
UUID_FILE="/logs/${CS_SESSION_ID}.session-uuid"

# Read the initial prompt (optional in interactive mode, required in bg mode).
PROMPT=""
if [[ -n "${CS_PROMPT_FILE:-}" && -f "$CS_PROMPT_FILE" ]]; then
  PROMPT="$(cat "$CS_PROMPT_FILE")"
fi

# ---- background / headless mode ---------------------------------------------
if [[ "$MODE" == "bg" ]]; then
  [[ -n "$PROMPT" ]] || { echo "bg mode requires CS_PROMPT_FILE" >&2; exit 2; }
  LOG="/logs/${CS_SESSION_ID}.jsonl"

  if [[ -n "${CS_RESUME_UUID:-}" ]]; then
    exec claude \
      --permission-mode auto \
      --resume "$CS_RESUME_UUID" \
      -p "$PROMPT" \
      --output-format stream-json \
      --include-partial-messages \
      --verbose \
      >> "$LOG" 2>&1
  fi

  SESSION_UUID="$(uuidgen | tr '[:upper:]' '[:lower:]')"
  echo "$SESSION_UUID" > "$UUID_FILE"

  exec claude \
    --permission-mode auto \
    -p "$PROMPT" \
    --session-id "$SESSION_UUID" \
    --output-format stream-json \
    --include-partial-messages \
    --verbose \
    > "$LOG" 2>&1
fi

# ---- interactive mode (default) ---------------------------------------------
if [[ -n "${CS_RESUME_UUID:-}" ]]; then
  if [[ -n "$PROMPT" ]]; then
    exec claude --permission-mode auto --resume "$CS_RESUME_UUID" "$PROMPT"
  else
    exec claude --permission-mode auto --resume "$CS_RESUME_UUID"
  fi
fi

SESSION_UUID="$(uuidgen | tr '[:upper:]' '[:lower:]')"
echo "$SESSION_UUID" > "$UUID_FILE"

if [[ -n "$PROMPT" ]]; then
  exec claude --permission-mode auto --session-id "$SESSION_UUID" "$PROMPT"
else
  exec claude --permission-mode auto --session-id "$SESSION_UUID"
fi
