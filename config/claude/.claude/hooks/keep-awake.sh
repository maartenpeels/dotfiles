#!/bin/sh
# Keeps the machine awake while Claude works on a prompt.
# Usage: keep-awake.sh start|stop, with the hook's JSON on stdin.

set -eu

# Both variants exit with the Claude process ($1), so a crash or an interrupted prompt (no Stop hook)
# can't keep the machine awake after the session is gone.
if command -v caffeinate >/dev/null 2>&1; then
    inhibit() { exec caffeinate -is -w "$1"; }
elif command -v systemd-inhibit >/dev/null 2>&1; then
    inhibit() {
        exec systemd-inhibit --what=idle:sleep --who="Claude Code" --why="Working on a prompt" \
            tail --pid="$1" -f /dev/null
    }
else
    exit 0
fi

session="$(sed -n 's/.*"session_id" *: *"\([^"]*\)".*/\1/p' | head -n 1)"
[ -n "$session" ] || exit 0
pidfile="${TMPDIR:-/tmp}/claude-keep-awake-$session.pid"

release() {
    [ -f "$pidfile" ] || return 0
    pid="$(cat "$pidfile")"
    # systemd-inhibit doesn't pass SIGTERM on to its child
    pkill -P "$pid" 2>/dev/null || true
    kill "$pid" 2>/dev/null || true
    rm -f "$pidfile"
}

case "${1:-}" in
    start)
        release
        inhibit "$PPID" </dev/null >/dev/null 2>&1 &
        echo $! >"$pidfile"
        ;;
    stop)
        release
        ;;
esac
