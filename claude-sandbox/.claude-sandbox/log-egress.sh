#!/usr/bin/env bash
# Passive egress logging: record every DNS lookup made from this container.
# Writes one DNS domain per line to /logs/<id>.net.log (bind-mounted from
# ~/.local/state/claude-sandbox/logs/ on the host).
set -u

ID="${1:?usage: log-egress.sh <session-id>}"
OUT="/logs/${ID}.net.log"
: > "$OUT"

# -Z root: keep tcpdump running as root. Debian's build drops to user
#   `tcpdump` by default, which silently fails to capture inside Docker.
# -W interactive: tell mawk (Debian's default awk) to line-buffer input.
#   Without this, mawk waits for a 4KB input block and never processes the
#   trickle of DNS output tcpdump produces during a short session.
tcpdump -Z root -n -l -U -i any 'udp port 53' 2>/dev/null \
  | awk -W interactive '/ A\? / {
      name = $(NF-1)
      sub(/\.$/, "", name)
      print strftime("%Y-%m-%dT%H:%M:%S"), "dns", name
      fflush()
    }' >> "$OUT"
