#!/usr/bin/env python3
"""Check shell abbreviations, interactive wrappers, and required plugins."""
import json
import subprocess
import sys
from pathlib import Path


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


config = json.loads(Path(sys.argv[1]).read_text())
require(not config["aliases"], "Do not register custom aliases")
require(
    set(config["functionNames"]) == {"cat", "ls"},
    "Only the interactive cat/ls wrappers are allowed",
)
for name, body in config["functions"].items():
    require("status is-interactive" in body["body"], f"{name}: wrapper must be interactive-only")
require("command cat" in config["functions"]["cat"]["body"], "cat must preserve coreutils fallback")
require("command ls" in config["functions"]["ls"]["body"], "ls must preserve coreutils fallback")
expected = {"..", "...", "ll", "lg", "v", "y", "clip", "tg"}
require(set(config["abbrs"]) == expected, "Only the eight custom daily-tool abbreviations are allowed")
required_plugins = {"git-abbr", "fish-you-should-use", "forgit"}
require(required_plugins <= set(config["plugins"]), "Required fish plugins are missing")

for name, expansion in config["abbrs"].items():
    require(isinstance(expansion, str), f"{name}: use a simple, visible command")
    result = subprocess.run(
        ["fish", "--no-config", "--no-execute"],
        input=expansion,
        text=True,
        capture_output=True,
        timeout=15,
    )
    require(result.returncode == 0, f"{name}: {result.stderr}")

print("Shell wrappers, eight abbreviations, and required plugins checked.")
