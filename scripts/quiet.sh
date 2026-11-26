#!/usr/bin/env bash
# 명령을 실행하되 출력은 $LOG 파일로만 보낸다(공개 로그에는 종료 코드와 걸린 시간만).
# requirements.txt가 있으면 먼저 설치한다.
set -uo pipefail
: "${LOG:?}"
start=$(date +%s)
{
  echo "### $(date -u +%FT%TZ) $REPO@$REF"
  if [ -f requirements.txt ]; then
    python -m pip install -q -r requirements.txt
  fi
  echo "### cmd"
  "$@"
} >>"$LOG" 2>&1
rc=$?
echo "종료 코드 $rc, $(( $(date +%s) - start ))초"
exit $rc
