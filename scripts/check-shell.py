#!/usr/bin/env python3
"""Check custom abbreviations and required plugins without executing shortcuts."""
import json
import subprocess
import sys
from pathlib import Path


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


config = json.loads(Path(sys.argv[1]).read_text())
require(not config["aliases"], "Do not register custom aliases")
require(not config["functionNames"], "Do not register shortcut functions")
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

print("Eight custom abbreviations and required plugins checked; plugin shortcuts are preserved.")
