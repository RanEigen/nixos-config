#!/usr/bin/env python3
"""Check known repository boundaries; not a replacement for module review."""
import re
import sys
from pathlib import Path

root = Path(sys.argv[1]).resolve() if len(sys.argv) > 1 else Path(__file__).resolve().parents[1]
errors = []
docs = [p.name for p in (root / "docs/troubleshooting").glob("*.md")]
files = [root / "flake.nix"]
for directory in ("config", "flake", "profiles", "modules", "home", "hosts"):
    files.extend((root / directory).rglob("*.nix"))

for path in files:
    text = path.read_text()
    relative = path.relative_to(root)
    if path.name == "hardware-configuration.nix":
        continue
    for ref in re.findall(r"REF:(\d{4}-\d{2}-\d{2}-[A-Za-z0-9-]+)", text):
        if not any(ref in name for name in docs):
            errors.append(f"{relative}: missing incident document: {ref}")
    if relative.parts[0] in ("modules", "home", "profiles"):
        if re.search(r"\b(?:fcclient|fcclientCore|fcproxy_port|omen-rs|HDMI-A-1|eDP-1)\b", text):
            errors.append(f"{relative}: host-specific identifier in shared layer")
        if re.search(r"(?:\.\./|\./)hosts/", text):
            errors.append(f"{relative}: shared layer imports a host")
    if path.name == "default.nix":
        lines = [line.split("#", 1)[0] for line in text.splitlines()]
        code = "\n".join(lines)
        if not re.fullmatch(r"\s*\{\s*imports\s*=\s*\[[^\]]*\];\s*\}\s*", code):
            errors.append(f"{relative}: default.nix must only aggregate imports")
        for line in text.splitlines():
            if re.match(r"\s*\.{1,2}/", line) and "#" not in line:
                errors.append(f"{relative}: import needs a short responsibility comment")
    if "builtins.getEnv" in text:
        errors.append(f"{relative}: undeclared environment input")

if errors:
    print("\n".join(errors), file=sys.stderr)
    sys.exit(1)
print(f"Architecture boundaries checked across {len(files)} Nix files.")
