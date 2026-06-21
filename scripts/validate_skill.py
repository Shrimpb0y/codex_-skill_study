from __future__ import annotations

import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SKILL_DIRS = (ROOT / "skill-study", ROOT / "skill-mindmap")
MOJIBAKE_MARKERS = tuple(
    chr(codepoint) for codepoint in (0x93B4, 0x951B, 0x9286, 0x9225, 0x7ED4, 0x701B)
)


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    raise SystemExit(1)


def read_utf8(path: Path) -> str:
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError as exc:
        fail(f"{path.relative_to(ROOT)} is not valid UTF-8: {exc}")


def validate_frontmatter(skill_dir: Path, text: str) -> None:
    match = re.match(r"\A---\n(.*?)\n---\n", text, re.DOTALL)
    if not match:
        fail(f"{skill_dir.name}/SKILL.md has invalid YAML frontmatter delimiters")

    fields = {}
    for line in match.group(1).splitlines():
        key, separator, value = line.partition(":")
        if not separator:
            fail(f"invalid frontmatter line: {line}")
        fields[key.strip()] = value.strip()

    if set(fields) != {"name", "description"}:
        fail("frontmatter must contain only name and description")
    if fields["name"] != skill_dir.name:
        fail("frontmatter name must match the skill directory")
    if not fields["description"]:
        fail("frontmatter description must not be empty")


def main() -> None:
    required = (
        ROOT / "skill-study" / "SKILL.md",
        ROOT / "skill-study" / "agents" / "openai.yaml",
        ROOT / "skill-study" / "references" / "assessment-rubric.md",
        ROOT / "skill-study" / "references" / "teaching-workflow.md",
        ROOT / "skill-mindmap" / "SKILL.md",
        ROOT / "skill-mindmap" / "agents" / "openai.yaml",
        ROOT / "skill-mindmap" / "scripts" / "generate_mindmap.ps1",
    )
    for path in required:
        if not path.is_file():
            fail(f"missing required file: {path.relative_to(ROOT)}")

    text_suffixes = {".md", ".py", ".ps1", ".yaml", ".yml"}
    texts = {
        path: read_utf8(path)
        for path in ROOT.rglob("*")
        if path.is_file() and path.suffix.lower() in text_suffixes
    }
    for skill_dir in SKILL_DIRS:
        validate_frontmatter(skill_dir, texts[skill_dir / "SKILL.md"])

    for path, text in texts.items():
        markers = sorted({marker for marker in MOJIBAKE_MARKERS if marker in text})
        if markers:
            fail(f"possible mojibake in {path.relative_to(ROOT)}: {', '.join(markers)}")

    study_dir = ROOT / "skill-study"
    skill_text = texts[study_dir / "SKILL.md"]
    for reference in re.findall(r"`(references/[^`]+)`", skill_text):
        if not (study_dir / reference).is_file():
            fail(f"missing referenced file: skill-study/{reference}")

    for skill_dir in SKILL_DIRS:
        metadata = texts[skill_dir / "agents" / "openai.yaml"]
        invocation = f"${skill_dir.name}"
        if invocation not in metadata:
            fail(f"{skill_dir.name}/agents/openai.yaml must mention {invocation}")

    print("Skill validation passed.")


if __name__ == "__main__":
    main()
