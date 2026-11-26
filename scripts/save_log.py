"""실행 로그($LOG)를 비공개 저장소($REPO)의 runner-logs 브랜치에 올린다.

공개 로그에는 저장 위치만 찍는다. 로그가 크면 뒤쪽 2MB만 남긴다.
"""
import base64
import json
import os
import subprocess
import sys

repo = os.environ["REPO"]
log = os.environ["LOG"]
run_id = os.environ.get("GITHUB_RUN_ID", "local")
attempt = os.environ.get("GITHUB_RUN_ATTEMPT", "1")
branch = "runner-logs"


def gh(*args, input_json=None):
    r = subprocess.run(
        ["gh", "api", *args] + (["--input", "-"] if input_json is not None else []),
        input=json.dumps(input_json) if input_json is not None else None,
        capture_output=True,
        text=True,
    )
    return r.returncode, r.stdout


if not os.path.exists(log):
    print("로그 없음")
    sys.exit(0)

data = open(log, "rb").read()[-2_000_000:]

rc, _ = gh(f"repos/{repo}/git/ref/heads/{branch}")
if rc != 0:
    rc, out = gh(f"repos/{repo}/commits/HEAD", "--jq", ".sha")
    if rc == 0:
        gh(f"repos/{repo}/git/refs", "-X", "POST",
           input_json={"ref": f"refs/heads/{branch}", "sha": out.strip()})

path = f"runner-logs/{run_id}-{attempt}.log"
rc, _ = gh(f"repos/{repo}/contents/{path}", "-X", "PUT", input_json={
    "message": f"runner 로그 {run_id}",
    "content": base64.b64encode(data).decode(),
    "branch": branch,
    "committer": {"name": "github-actions[bot]",
                  "email": "41898282+github-actions[bot]@users.noreply.github.com"},
})
print(f"로그 저장: {branch}/{path}" if rc == 0 else "로그 저장 실패")
