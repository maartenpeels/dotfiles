#!/bin/sh
# SubagentStart: split the herdr pane this session runs in and follow the subagent's
# transcript there. SubagentStop: close that pane again. No-op outside herdr.
set -eu

[ "${HERDR_ENV:-}" = 1 ] || exit 0
[ -n "${HERDR_PANE_ID:-}" ] || exit 0
command -v herdr >/dev/null 2>&1 || exit 0
command -v python3 >/dev/null 2>&1 || exit 0

VIEWER="$(cd "$(dirname "$0")" && pwd)/subagent-transcript.py"
STATE_ROOT="${XDG_STATE_HOME:-$HOME/.local/state}/claude-herdr-subagents"
# The heredoc below takes over python's stdin, so the hook payload is captured first.
HOOK_INPUT="$(cat)"

HOOK_INPUT="$HOOK_INPUT" VIEWER="$VIEWER" STATE_ROOT="$STATE_ROOT" python3 - <<'PY' || true
import json
import os
import shlex
import subprocess
import sys
import time

try:
    hook = json.loads(os.environ["HOOK_INPUT"])
except Exception:
    sys.exit(0)

event = hook.get("hook_event_name")
agent_id = hook.get("agent_id")
session = hook.get("session_id")
if not (event and agent_id and session):
    sys.exit(0)

parent_pane = os.environ["HERDR_PANE_ID"]
viewer = os.environ["VIEWER"]
state_dir = os.path.join(os.environ["STATE_ROOT"], session)
os.makedirs(state_dir, exist_ok=True)
state_file = os.path.join(state_dir, agent_id)
latest_file = os.path.join(state_dir, ".latest")


def herdr(*args, check=True):
    result = subprocess.run(["herdr", *args], capture_output=True, text=True, timeout=8)
    if result.returncode != 0:
        if check:
            raise RuntimeError(result.stderr.strip() or f"herdr {' '.join(args)} failed")
        return None
    out = result.stdout.strip()
    return json.loads(out) if out.startswith("{") else None


def read(path):
    try:
        with open(path, encoding="utf-8") as handle:
            return handle.read().strip()
    except OSError:
        return ""


def write(path, value):
    with open(path, "w", encoding="utf-8") as handle:
        handle.write(value + "\n")


def pane_exists(pane_id):
    return herdr("pane", "get", pane_id, check=False) is not None


def wait_for_shell(pane_id, timeout=8.0):
    # Text sent while the shell is still initialising (direnv, stty) is lost, so
    # wait until the shell itself is the only foreground process.
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        info = herdr("pane", "process-info", "--pane", pane_id, check=False)
        if info:
            proc = info["result"]["process_info"]
            fg = proc.get("foreground_processes") or []
            if len(fg) == 1 and fg[0].get("pid") == proc.get("shell_pid"):
                return True
        time.sleep(0.2)
    return False


def split_direction(pane_id):
    # Terminal cells are about twice as tall as wide, so a pane only counts as
    # "wide" well past a 2:1 cell ratio.
    layout = herdr("pane", "layout", "--pane", pane_id)
    for pane in layout["result"]["layout"]["panes"]:
        if pane["pane_id"] == pane_id:
            rect = pane["rect"]
            return "right" if rect["width"] > 2.2 * rect["height"] else "down"
    return "down"


if event == "SubagentStart":
    transcript = hook.get("transcript_path")
    if not transcript:
        sys.exit(0)
    target, direction = parent_pane, split_direction(parent_pane)
    latest = read(latest_file)
    if latest and pane_exists(latest):
        target, direction = latest, "down"
    cwd = hook.get("cwd") or os.getcwd()
    created = herdr("pane", "split", "--pane", target, "--direction", direction, "--cwd", cwd, "--no-focus")
    new_pane = created["result"]["pane"]["pane_id"]
    label = hook.get("agent_name") or hook.get("agent_type") or "subagent"
    herdr("pane", "rename", new_pane, label, check=False)
    command = f"exec python3 {shlex.quote(viewer)} {shlex.quote(transcript)} {shlex.quote(label)}"
    wait_for_shell(new_pane)
    herdr("pane", "run", new_pane, command)
    write(state_file, new_pane)
    write(latest_file, new_pane)

elif event == "SubagentStop":
    pane_id = read(state_file)
    if pane_id:
        herdr("pane", "close", pane_id, check=False)
        os.remove(state_file)
        if read(latest_file) == pane_id:
            os.remove(latest_file)
PY

exit 0
