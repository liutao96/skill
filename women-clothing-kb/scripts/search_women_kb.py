from __future__ import annotations

import argparse
import csv
import json
import os
import sys
from pathlib import Path
from typing import Any


DEFAULT_REL = Path("projects-test") / "短视频带货项目" / "女装赛道" / "提示词和教程知识库"


def candidate_roots() -> list[Path]:
    roots: list[Path] = []
    env = os.environ.get("WOMEN_CLOTHING_KB_ROOT")
    if env:
        roots.append(Path(env))
    for drive in ["P:", "E:", "D:", "F:", "G:"]:
        roots.append(Path(drive + "\\") / DEFAULT_REL)
    roots.append(Path.cwd())
    return roots


def find_root(explicit: str | None = None) -> Path:
    candidates = [Path(explicit)] if explicit else candidate_roots()
    for root in candidates:
        if (root / "00_女装提示词知识库").exists() and (root / "AGENTS.md").exists():
            return root
    checked = "\n".join(str(p) for p in candidates)
    raise SystemExit(f"Knowledge base root not found. Set WOMEN_CLOTHING_KB_ROOT or pass --kb-root.\nChecked:\n{checked}")


def kb(root: Path) -> Path:
    return root / "00_女装提示词知识库"


def read_json(path: Path, default: Any) -> Any:
    if not path.exists():
        return default
    return json.loads(path.read_text(encoding="utf-8"))


def read_jsonl(path: Path):
    if not path.exists():
        return
    with path.open("r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                yield json.loads(line)


def read_csv(path: Path) -> list[dict[str, str]]:
    if not path.exists():
        return []
    with path.open("r", encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f))


def compact(value: Any, limit: int = 260) -> str:
    if value is None:
        text = ""
    elif isinstance(value, str):
        text = value
    else:
        text = json.dumps(value, ensure_ascii=False)
    text = " ".join(text.split())
    return text if len(text) <= limit else text[: limit - 1] + "…"


def score_text(text: str, terms: list[str]) -> int:
    text_lower = text.lower()
    score = 0
    for term in terms:
        term = term.strip()
        if not term:
            continue
        score += text_lower.count(term.lower()) * 3
        if term.lower() in text_lower:
            score += 2
    return score


def split_terms(query: str) -> list[str]:
    defaults = ["女装", "衣服", "穿搭"]
    terms = [t for t in query.replace(",", " ").replace("，", " ").split() if t]
    return terms or defaults


def prompt_records(root: Path, task: str, query: str, limit: int) -> list[dict[str, Any]]:
    terms = split_terms(query)
    if task == "video-prompt":
        terms += ["视频动态提示词", "视频提示词", "生视频", "动图&实况图", "运镜", "镜头跟随", "动作自然流畅"]
    elif task == "image-prompt":
        terms += ["提示词", "场景", "商品图", "真人上身", "对镜自拍"]

    records: list[tuple[int, str, dict[str, Any]]] = []
    sources = [
        ("case", kb(root) / "10_完整案例库" / "cases.jsonl"),
        ("base", kb(root) / "13_飞书Base案例库" / "feishu_base_cases.jsonl"),
    ]
    for source_name, path in sources:
        for row in read_jsonl(path) or []:
            prompt = str(row.get("prompt", ""))
            search_text = " ".join(
                [
                    str(row.get("source_path", "")),
                    str(row.get("scene", "")),
                    prompt,
                    json.dumps(row.get("fields", {}), ensure_ascii=False),
                ]
            )
            score = score_text(search_text, terms)
            if task == "video-prompt" and not any(t in search_text for t in ["视频", "动图", "运镜", "镜头", "动作自然流畅", "生视频"]):
                continue
            if score > 0 and prompt.strip():
                records.append((score, source_name, row))

    records.sort(key=lambda item: item[0], reverse=True)
    output = []
    for score, source_name, row in records[:limit]:
        output.append(
            {
                "score": score,
                "module": source_name,
                "case_id": row.get("case_id", ""),
                "source_path": row.get("source_path", ""),
                "scene": row.get("scene", row.get("table_name", "")),
                "prompt": compact(row.get("prompt", ""), 900),
                "assets": row.get("image_assets") or row.get("attachments") or [],
            }
        )
    return output


def media_records(root: Path, query: str, limit: int) -> list[dict[str, Any]]:
    terms = split_terms(query)
    rows: list[tuple[int, dict[str, Any]]] = []
    path = kb(root) / "16_多媒体资产调用索引" / "media_assets.jsonl"
    for row in read_jsonl(path) or []:
        text = json.dumps(row, ensure_ascii=False)
        score = score_text(text, terms)
        if score > 0:
            rows.append((score, row))
    rows.sort(key=lambda item: item[0], reverse=True)
    return [
        {
            "score": score,
            "asset_type": row.get("asset_type"),
            "asset_path": row.get("asset_path"),
            "source_path": row.get("source_path"),
            "prompt_preview": row.get("prompt_preview") or row.get("context_preview", ""),
            "exists": row.get("exists"),
        }
        for score, row in rows[:limit]
    ]


def transcript_records(root: Path, query: str, limit: int) -> list[dict[str, Any]]:
    terms = split_terms(query)
    rows: list[tuple[int, dict[str, Any]]] = []
    for path in (kb(root) / "11_视频课程库" / "transcripts").glob("*.md"):
        text = path.read_text(encoding="utf-8", errors="ignore")
        score = score_text(path.name + "\n" + text, terms)
        if score > 0:
            rows.append(
                (
                    score,
                    {
                        "transcript_path": str(path.relative_to(root)).replace("\\", "/"),
                        "preview": compact(text, 900),
                    },
                )
            )
    rows.sort(key=lambda item: item[0], reverse=True)
    return [{"score": score, **row} for score, row in rows[:limit]]


def audit(root: Path) -> dict[str, Any]:
    audit_json = read_json(kb(root) / "14_知识库完整性审计.json", {})
    media_json = read_json(kb(root) / "16_多媒体资产调用索引" / "media_asset_summary.json", {})
    return {
        "kb_root": str(root),
        "gaps": len(audit_json.get("gaps", [])),
        "source_file_count": audit_json.get("source_file_count"),
        "case_library": audit_json.get("case_library"),
        "video_library": audit_json.get("video_library"),
        "feishu_base": audit_json.get("feishu_base"),
        "media_asset_index": media_json,
    }


def main() -> None:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    parser = argparse.ArgumentParser()
    parser.add_argument("--task", choices=["video-prompt", "image-prompt", "media", "transcript", "audit"], default="video-prompt")
    parser.add_argument("--query", default="")
    parser.add_argument("--limit", type=int, default=8)
    parser.add_argument("--kb-root", default=None)
    args = parser.parse_args()

    root = find_root(args.kb_root)
    if args.task == "audit":
        result: Any = audit(root)
    elif args.task in {"video-prompt", "image-prompt"}:
        result = prompt_records(root, args.task, args.query, args.limit)
    elif args.task == "media":
        result = media_records(root, args.query, args.limit)
    else:
        result = transcript_records(root, args.query, args.limit)

    print(json.dumps({"kb_root": str(root), "task": args.task, "query": args.query, "results": result}, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
