#!/usr/bin/env python3
"""Convert Gemini CLI TOML commands to Claude Code Markdown format.

Usage:
    python3 scripts/toml_to_md.py commands/repokit.toml
    python3 scripts/toml_to_md.py commands/repokit.toml commands/repokit.md
    python3 scripts/toml_to_md.py commands/          # convert all .toml in a dir
"""

import sys
import pathlib
import tomllib


def convert(toml_path: pathlib.Path) -> str:
    data = tomllib.loads(toml_path.read_text())

    description = data.get("description", "")

    # Gemini supports two prompt formats:
    #   prompt = "..."                    (simple string)
    #   [[command.prompts]] content = "..." (array of typed messages)
    if "prompt" in data:
        body = data["prompt"].strip()
    elif "command" in data and "prompts" in data.get("command", {}):
        parts = [p.get("content", "") for p in data["command"]["prompts"]]
        body = "\n\n".join(p.strip() for p in parts if p)
    else:
        body = ""

    return f"---\ndescription: {description}\n---\n\n{body}\n"


def process(toml_path: pathlib.Path, md_path: pathlib.Path | None = None) -> None:
    md_path = md_path or toml_path.with_suffix(".md")
    md_path.write_text(convert(toml_path))
    print(f"✓ {toml_path} → {md_path}")


def main() -> None:
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    target = pathlib.Path(sys.argv[1])

    if target.is_dir():
        files = list(target.glob("*.toml"))
        if not files:
            print(f"No .toml files found in {target}")
            sys.exit(1)
        for f in files:
            process(f)
    elif target.suffix == ".toml":
        out = pathlib.Path(sys.argv[2]) if len(sys.argv) > 2 else None
        process(target, out)
    else:
        print(f"Expected a .toml file or directory, got: {target}")
        sys.exit(1)


if __name__ == "__main__":
    main()
