import argparse
from datetime import date
from pathlib import Path


def clean(value: str) -> str:
    return " ".join(value.strip().split())


def main() -> None:
    parser = argparse.ArgumentParser(description="Append a solved pitfall to lufei-lessons.")
    parser.add_argument("--title", required=True)
    parser.add_argument("--context", required=True)
    parser.add_argument("--root-cause", required=True)
    parser.add_argument("--fix", required=True)
    parser.add_argument("--verify", required=True)
    parser.add_argument("--prevention", required=True)
    parser.add_argument("--date", default=date.today().isoformat())
    args = parser.parse_args()

    skill_dir = Path(__file__).resolve().parents[1]
    log_path = skill_dir / "references" / "lesson-log.md"
    log_path.parent.mkdir(parents=True, exist_ok=True)

    entry = f"""
## {clean(args.date)} - {clean(args.title)}

- Context: {clean(args.context)}
- Root cause: {clean(args.root_cause)}
- Fix: {clean(args.fix)}
- Verification: {clean(args.verify)}
- Prevention: {clean(args.prevention)}
"""

    with log_path.open("a", encoding="utf-8", newline="\n") as f:
        f.write(entry)

    print(f"Appended lesson to {log_path}")


if __name__ == "__main__":
    main()
