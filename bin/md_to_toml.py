#!/usr/bin/env python3
"""Convert Claude Code Markdown commands to Gemini CLI TOML format.

Usage:
    python3 bin/md_to_toml.py commands/repokit.md
    python3 bin/md_to_toml.py commands/repokit.md commands/repokit.toml
    python3 bin/md_to_toml.py commands/          # convert all .md in a dir
"""

import sys
import pathlib


def parse_frontmatter(text: str) -> tuple[dict, str]:
    """Extract key:value frontmatter and body from a markdown string."""
    if not text.startswith("---"):
        return {}, text.strip()
    try:
        end = text.index("\n---", 3)
    except ValueError:
        return {}, text.strip()

    meta = {}
    for line in text[4:end].splitlines():
        if ":" in line:
            key, _, val = line.partition(":")
            meta[key.strip()] = val.strip().strip("\"'")

    return meta, text[end + 4:].strip()


def toml_escape(s: str) -> str:
    """Escape a string for use in a TOML double-quoted value."""
    return s.replace("\\", "\\\\").replace('"', '\\"')


def convert(md_path: pathlib.Path) -> str:
    meta, body = parse_frontmatter(md_path.read_text())

    description = toml_escape(meta.get("description", ""))

    # Escape """ sequences inside TOML multiline basic strings
    body = body.replace('"""', '""\\"')

    return f'description = "{description}"\n\nprompt = """\n{body}\n"""\n'


def process(md_path: pathlib.Path, toml_path: pathlib.Path | None = None) -> None:
    toml_path = toml_path or md_path.with_suffix(".toml")
    toml_path.write_text(convert(md_path))
    print(f"✓ {md_path} → {toml_path}")


def main() -> None:
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    target = pathlib.Path(sys.argv[1])

    if target.is_dir():
        files = list(target.glob("*.md"))
        if not files:
            print(f"No .md files found in {target}")
            sys.exit(1)
        for f in files:
            process(f)
    elif target.suffix == ".md":
        out = pathlib.Path(sys.argv[2]) if len(sys.argv) > 2 else None
        process(target, out)
    else:
        print(f"Expected a .md file or directory, got: {target}")
        sys.exit(1)


if __name__ == "__main__":
    main()
