#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Search Liu Tao's local Douyin traffic-operation knowledge base."""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from pathlib import Path


DEFAULT_REL = Path("projects-test") / "短视频带货项目" / "投流和流程运营教程"
KB_DIR_NAME = "抖音运营知识库"
DEFAULT_ROOT = Path(r"P:\projects-test\短视频带货项目\投流和流程运营教程\抖音运营知识库")
SEARCH_DIRS = [
    "05_日常运营问答库",
    "04_主题索引",
    "03_课程精华总结",
    "01_课程逐字稿",
    "06_质量检查",
]


def is_kb_root(path: Path) -> bool:
    return (
        (path / "README.md").exists()
        and (path / "00_处理清单").exists()
        and (path / "04_主题索引").exists()
    )


def normalize_candidate(path: Path) -> Path | None:
    if is_kb_root(path):
        return path
    nested = path / KB_DIR_NAME
    if is_kb_root(nested):
        return nested
    return None


def parent_candidates(start: Path) -> list[Path]:
    candidates = [start]
    if start.is_file():
        candidates.append(start.parent)
        parents = start.parent.parents
    else:
        parents = start.parents
    candidates.extend(list(parents)[:8])
    return candidates


def candidate_roots(explicit: str | None = None) -> list[Path]:
    raw: list[Path] = []
    if explicit:
        raw.append(Path(explicit))
    env = os.environ.get("DOUYIN_TOULIU_KB_ROOT")
    if env:
        raw.append(Path(env))

    raw.extend(parent_candidates(Path(__file__).resolve()))
    raw.extend(parent_candidates(Path.cwd().resolve()))

    for drive in ["P:", "F:", "E:", "D:", "G:"]:
        raw.append(Path(drive + "\\") / DEFAULT_REL)
        raw.append(Path(drive + "\\") / DEFAULT_REL / KB_DIR_NAME)

    raw.append(DEFAULT_ROOT)

    seen: set[str] = set()
    output: list[Path] = []
    for path in raw:
        key = str(path).lower()
        if key not in seen:
            seen.add(key)
            output.append(path)
    return output


def resolve_root(explicit: str | None = None) -> Path:
    checked: list[Path] = []
    for candidate in candidate_roots(explicit):
        checked.append(candidate)
        normalized = normalize_candidate(candidate)
        if normalized:
            return normalized
    raise SystemExit(
        "Knowledge base not found. Set DOUYIN_TOULIU_KB_ROOT, pass --kb-root, "
        "or keep the project folder with 抖音运营知识库 next to this skill.\nChecked:\n"
        + "\n".join(str(p) for p in checked)
    )


def tokenize(query: str) -> list[str]:
    parts = re.split(r"[\s,，。；;、/|]+", query.strip())
    return [p.lower() for p in parts if p.strip()]


def iter_markdown(root: Path) -> list[Path]:
    files: list[Path] = []
    for name in SEARCH_DIRS:
        path = root / name
        if path.exists():
            files.extend(sorted(path.rglob("*.md"), key=lambda p: str(p).lower()))
    return files


def score_text(path: Path, text: str, terms: list[str]) -> int:
    hay = (str(path) + "\n" + text).lower()
    score = 0
    for term in terms:
        count = hay.count(term)
        score += count * 10
        if term in path.name.lower():
            score += 30
    if "05_日常运营问答库" in str(path):
        score += 12
    if "04_主题索引" in str(path):
        score += 8
    if "03_课程精华总结" in str(path):
        score += 4
    return score


def snippet(text: str, terms: list[str], size: int = 220) -> str:
    lower = text.lower()
    pos = min([lower.find(t) for t in terms if lower.find(t) >= 0] or [0])
    start = max(0, pos - 70)
    raw = text[start : start + size]
    return re.sub(r"\s+", " ", raw).strip()


def search(query: str, limit: int, json_output: bool, kb_root: str | None) -> None:
    root = resolve_root(kb_root)
    terms = tokenize(query)
    if not terms:
        raise SystemExit("Please provide a non-empty query.")

    results = []
    for path in iter_markdown(root):
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            text = path.read_text(encoding="utf-8-sig", errors="replace")
        score = score_text(path, text, terms)
        if score <= 0:
            continue
        results.append(
            {
                "score": score,
                "path": str(path),
                "relative_path": str(path.relative_to(root)),
                "snippet": snippet(text, terms),
            }
        )

    results.sort(key=lambda r: (-int(r["score"]), str(r["relative_path"]).lower()))
    results = results[:limit]

    if json_output:
        print(json.dumps(results, ensure_ascii=False, indent=2))
        return

    if not results:
        print("No local matches found.")
        return

    for idx, row in enumerate(results, 1):
        print(f"{idx}. [{row['score']}] {row['relative_path']}")
        print(f"   {row['path']}")
        print(f"   {row['snippet']}")


def main() -> None:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    parser = argparse.ArgumentParser()
    parser.add_argument("query", help="Search query, e.g. '随心推 测品 ROI'")
    parser.add_argument("--limit", type=int, default=8)
    parser.add_argument("--json", action="store_true", dest="json_output")
    parser.add_argument("--kb-root", default=None, help="Knowledge base root or project root")
    args = parser.parse_args()
    search(args.query, args.limit, args.json_output, args.kb_root)


if __name__ == "__main__":
    main()
