#!/bin/sh
# commit-msg hook: append `Co-authored-by: <host-user>` to every commit
# made inside the sandbox. The host user's name/email are injected by the
# claude-sandbox wrapper via CS_CO_AUTHOR_NAME / CS_CO_AUTHOR_EMAIL.
#
# Idempotent via `git interpret-trailers --if-exists doNothing`.
set -eu

msg_file="$1"
[ -n "${CS_CO_AUTHOR_NAME:-}" ] || exit 0
[ -n "${CS_CO_AUTHOR_EMAIL:-}" ] || exit 0

trailer="Co-authored-by: ${CS_CO_AUTHOR_NAME} <${CS_CO_AUTHOR_EMAIL}>"

git interpret-trailers \
  --if-exists doNothing \
  --trailer "$trailer" \
  --in-place "$msg_file"
