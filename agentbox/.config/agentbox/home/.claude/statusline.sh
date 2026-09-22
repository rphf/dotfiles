#!/usr/bin/env bash
set -uo pipefail
input=$(cat)

# null before the first API response and again after /compact, until the next call repopulates it.
context=$(printf '%s' "$input" | jq -r '
  (.context_window.used_percentage // null) as $p |
  if $p == null then "ctx —" else "ctx \(($p)|round)%" end')
quota=$(printf '%s' "$input" | jq -r '
  (.rate_limits.five_hour.used_percentage // null) as $h |
  (.rate_limits.seven_day.used_percentage // null) as $w |
  if $h == null then "quota —"
  else "5h \(($h)|round)%  7d \((($w // 0))|round)%" end')
model=$(printf '%s' "$input" | jq -r '.model.display_name // ""')

links=""
if [ -n "${AGENT_NAME:-}" ]; then
  hy() { printf '\033]8;;%s\033\\%s\033]8;;\033\\' "$1" "$2"; }
  app=$(timeout 1 app url 2>/dev/null | head -n1)
  [ -z "$app" ] && [ -n "${APP_DOMAIN:-}" ] && app="http://${APP_DOMAIN}"
  [ -n "$app" ]                  && links+="  $(hy "$app" '↗app')"
  [ -n "${REVUE_PUBLIC_URL:-}" ] && links+="  $(hy "$REVUE_PUBLIC_URL" '↗revue')"
  [ -n "${OUT_PORT:-}" ]         && links+="  $(hy "http://${AGENT_HOST}:${OUT_PORT}" '↗out')"
  [ -n "$links" ] && links="  ·  agent ${AGENT}${links}"
fi

printf '%s  %s  ·  %s%s\n' "${model:+[$model]}" "$context" "$quota" "$links"
