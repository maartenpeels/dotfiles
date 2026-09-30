#!/usr/bin/env python3
"""Follow a Claude Code subagent transcript (JSONL) and print it as a readable log.

Usage: subagent-transcript.py <transcript.jsonl> [title]
Started by herdr-subagent-pane.sh in a split pane; runs until the pane is closed.
"""
import json
import os
import shutil
import sys
import textwrap
import time

DIM = "\033[2m"
BOLD = "\033[1m"
CYAN = "\033[36m"
YELLOW = "\033[33m"
RESET = "\033[0m"

INPUT_SUMMARY_KEYS = ("description", "command", "file_path", "pattern", "query", "prompt", "url", "skill", "to")


def width():
    return max(40, shutil.get_terminal_size((100, 40)).columns - 1)


def summarize_input(inp):
    for key in INPUT_SUMMARY_KEYS:
        value = inp.get(key)
        if isinstance(value, str) and value.strip():
            return value.strip().splitlines()[0]
    return json.dumps(inp)[:200] if inp else ""


def result_text(content):
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        return " ".join(p.get("text", "") for p in content if isinstance(p, dict))
    return ""


def render(entry):
    if entry.get("type") not in ("user", "assistant"):
        return []
    message = entry.get("message") or {}
    role = message.get("role")
    content = message.get("content")
    cols = width()
    lines = []
    if isinstance(content, str):
        if role == "user" and content.strip():
            lines.append(f"{BOLD}{YELLOW}prompt{RESET} {content.strip()[: cols * 6]}")
        return lines
    if not isinstance(content, list):
        return lines
    for part in content:
        kind = part.get("type")
        if kind == "text":
            text = part.get("text", "").strip()
            if not text:
                continue
            if role == "assistant":
                lines.append(textwrap.fill(text, cols, replace_whitespace=False))
            else:
                lines.append(f"{BOLD}{YELLOW}prompt{RESET} {text[: cols * 6]}")
        elif kind == "tool_use":
            summary = summarize_input(part.get("input") or {})
            lines.append(f"{CYAN}▸ {part.get('name')}{RESET} {summary[: cols - 4]}")
        elif kind == "tool_result":
            text = result_text(part.get("content")).strip()
            if text:
                lines.append(f"{DIM}  {text.splitlines()[0][: cols - 4]}{RESET}")
        elif kind == "thinking":
            lines.append(f"{DIM}  … thinking{RESET}")
    return lines


def follow(path):
    while not os.path.exists(path):
        time.sleep(0.2)
    with open(path, encoding="utf-8") as handle:
        buffer = ""
        while True:
            chunk = handle.read()
            if not chunk:
                time.sleep(0.3)
                continue
            buffer += chunk
            while "\n" in buffer:
                line, buffer = buffer.split("\n", 1)
                if not line.strip():
                    continue
                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    continue
                for out in render(entry):
                    print(out, flush=True)


def main():
    if len(sys.argv) < 2:
        print(__doc__, file=sys.stderr)
        return 2
    title = sys.argv[2] if len(sys.argv) > 2 else "subagent"
    print(f"{BOLD}{title}{RESET} {DIM}{sys.argv[1]}{RESET}", flush=True)
    try:
        follow(sys.argv[1])
    except KeyboardInterrupt:
        return 0
    return 0


if __name__ == "__main__":
    sys.exit(main())
