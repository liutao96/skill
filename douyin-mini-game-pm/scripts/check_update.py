import argparse
import json
import sys
import urllib.request
from pathlib import Path


def read_local_version(skill_dir: Path) -> str:
    version_file = skill_dir / "VERSION"
    if not version_file.exists():
        raise FileNotFoundError(f"VERSION not found: {version_file}")
    return version_file.read_text(encoding="utf-8").strip()


def read_manifest(skill_dir: Path) -> dict:
    manifest_file = skill_dir / "skill-release.json"
    if not manifest_file.exists():
        return {}
    return json.loads(manifest_file.read_text(encoding="utf-8"))


def version_tuple(value: str):
    parts = []
    for part in value.strip().split("."):
        try:
            parts.append(int(part))
        except ValueError:
            parts.append(part)
    return tuple(parts)


def github_raw_url(repo: str, branch: str, version_file: str) -> str:
    repo = repo.replace("https://github.com/", "").replace(".git", "").strip("/")
    if "/" not in repo:
        raise ValueError("repo must look like owner/repo or https://github.com/owner/repo")
    return f"https://raw.githubusercontent.com/{repo}/{branch}/{version_file}"


def fetch_remote_version(repo: str, branch: str, version_file: str) -> str:
    url = github_raw_url(repo, branch, version_file)
    with urllib.request.urlopen(url, timeout=20) as response:
        return response.read().decode("utf-8").strip()


def main() -> int:
    parser = argparse.ArgumentParser(description="Check whether this skill is up to date with GitHub.")
    parser.add_argument("--skill-dir", default=str(Path(__file__).resolve().parents[1]))
    parser.add_argument("--repo", default="", help="GitHub repo, e.g. owner/repo. Overrides skill-release.json.")
    parser.add_argument("--branch", default="main")
    args = parser.parse_args()

    skill_dir = Path(args.skill_dir).resolve()
    manifest = read_manifest(skill_dir)
    repo = args.repo or manifest.get("repository", "")
    version_file = manifest.get("versionFile", "VERSION")
    local = read_local_version(skill_dir)

    if not repo:
        print(json.dumps({
            "ok": False,
            "reason": "repository_not_configured",
            "localVersion": local,
            "message": "No GitHub repository is configured. Set skill-release.json.repository or pass --repo owner/repo."
        }, ensure_ascii=False, indent=2))
        return 2

    remote = fetch_remote_version(repo, args.branch, version_file)
    status = "up_to_date"
    if version_tuple(local) < version_tuple(remote):
        status = "outdated"
    elif version_tuple(local) > version_tuple(remote):
        status = "local_ahead"

    print(json.dumps({
        "ok": True,
        "status": status,
        "localVersion": local,
        "remoteVersion": remote,
        "repository": repo,
        "branch": args.branch
    }, ensure_ascii=False, indent=2))
    return 0 if status == "up_to_date" else 1


if __name__ == "__main__":
    sys.exit(main())
