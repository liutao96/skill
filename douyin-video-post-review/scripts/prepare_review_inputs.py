#!/usr/bin/env python3
"""Create a lightweight inventory for Douyin post-publish review inputs."""

from __future__ import annotations

import argparse
import csv
import json
import os
import subprocess
from pathlib import Path
from typing import Any


SPREADSHEET_EXTS = {".xlsx", ".xls", ".csv"}
IMAGE_EXTS = {".png", ".jpg", ".jpeg", ".webp", ".bmp"}
VIDEO_EXTS = {".mp4", ".mov", ".m4v", ".avi", ".mkv", ".webm"}


def iter_files(input_path: Path) -> list[Path]:
    if input_path.is_file():
        return [input_path]
    return [p for p in input_path.rglob("*") if p.is_file()]


def read_spreadsheet_summary(path: Path) -> dict[str, Any]:
    ext = path.suffix.lower()
    summary: dict[str, Any] = {"path": str(path), "type": ext.lstrip(".")}
    try:
        if ext == ".csv":
            with path.open("r", encoding="utf-8-sig", newline="") as f:
                reader = csv.reader(f)
                rows = []
                for idx, row in enumerate(reader):
                    rows.append(row)
                    if idx >= 5:
                        break
            summary["preview_rows"] = rows
            summary["columns"] = rows[0] if rows else []
            return summary

        import pandas as pd  # type: ignore

        xls = pd.ExcelFile(path)
        sheets = []
        for sheet in xls.sheet_names:
            df = pd.read_excel(path, sheet_name=sheet, nrows=5)
            sheets.append(
                {
                    "sheet": sheet,
                    "columns": [str(c) for c in df.columns.tolist()],
                    "preview_rows": df.fillna("").astype(str).values.tolist(),
                }
            )
        summary["sheets"] = sheets
    except Exception as exc:  # noqa: BLE001
        summary["error"] = str(exc)
    return summary


def probe_video(path: Path) -> dict[str, Any]:
    summary: dict[str, Any] = {"path": str(path), "type": path.suffix.lower().lstrip(".")}
    try:
        result = subprocess.run(
            [
                "ffprobe",
                "-v",
                "error",
                "-select_streams",
                "v:0",
                "-show_entries",
                "stream=width,height,duration,avg_frame_rate",
                "-of",
                "json",
                str(path),
            ],
            capture_output=True,
            text=True,
            check=False,
        )
        if result.returncode != 0:
            summary["error"] = result.stderr.strip() or "ffprobe failed"
            return summary
        data = json.loads(result.stdout or "{}")
        stream = (data.get("streams") or [{}])[0]
        summary.update(
            {
                "width": stream.get("width"),
                "height": stream.get("height"),
                "duration_seconds": stream.get("duration"),
                "avg_frame_rate": stream.get("avg_frame_rate"),
            }
        )
    except FileNotFoundError:
        summary["error"] = "ffprobe not found"
    except Exception as exc:  # noqa: BLE001
        summary["error"] = str(exc)
    return summary


def file_summary(path: Path) -> dict[str, Any]:
    stat = path.stat()
    return {
        "path": str(path),
        "size_bytes": stat.st_size,
        "modified_time": stat.st_mtime,
        "extension": path.suffix.lower(),
    }


def build_inventory(input_path: Path) -> dict[str, Any]:
    files = iter_files(input_path)
    inventory: dict[str, Any] = {
        "input": str(input_path),
        "counts": {"spreadsheets": 0, "images": 0, "videos": 0, "other": 0},
        "spreadsheets": [],
        "images": [],
        "videos": [],
        "other": [],
    }

    for path in files:
        ext = path.suffix.lower()
        base = file_summary(path)
        if ext in SPREADSHEET_EXTS:
            inventory["counts"]["spreadsheets"] += 1
            inventory["spreadsheets"].append(base | read_spreadsheet_summary(path))
        elif ext in IMAGE_EXTS:
            inventory["counts"]["images"] += 1
            inventory["images"].append(base)
        elif ext in VIDEO_EXTS:
            inventory["counts"]["videos"] += 1
            inventory["videos"].append(base | probe_video(path))
        else:
            inventory["counts"]["other"] += 1
            inventory["other"].append(base)
    return inventory


def main() -> int:
    parser = argparse.ArgumentParser(description="Prepare Douyin review input inventory.")
    parser.add_argument("--input", required=True, help="File or folder to inspect.")
    parser.add_argument("--output", help="Optional JSON output path.")
    args = parser.parse_args()

    input_path = Path(args.input).expanduser().resolve()
    if not input_path.exists():
        raise SystemExit(f"Input does not exist: {input_path}")

    inventory = build_inventory(input_path)
    text = json.dumps(inventory, ensure_ascii=False, indent=2)
    if args.output:
        output_path = Path(args.output).expanduser().resolve()
        output_path.parent.mkdir(parents=True, exist_ok=True)
        output_path.write_text(text, encoding="utf-8")
        print(str(output_path))
    else:
        print(text)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
