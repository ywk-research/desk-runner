#!/usr/bin/env bash
# $ADD 경로의 변경을 커밋해 $REF에 push한다. 작성자는 GitHub Actions 봇(noreply).
# git 출력은 $LOG로만 보내고 공개 로그에는 결과 요약만 남긴다.
set -uo pipefail
: "${LOG:?}" "${ADD:?}" "${REF:?}"
{
  git config user.name "github-actions[bot]"
  git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
  # shellcheck disable=SC2086
  git add -- $ADD
} >>"$LOG" 2>&1
if git diff --cached --quiet; then
  echo "바뀐 파일 없음"
  exit 0
fi
n=$(git diff --cached --name-only | wc -l)
git commit -q -m "${MSG:-runner 실행 결과}" >>"$LOG" 2>&1
for i in 1 2 3 4; do
  if git pull -q --rebase origin "$REF" >>"$LOG" 2>&1 && git push -q origin "HEAD:$REF" >>"$LOG" 2>&1; then
    echo "파일 ${n}개 커밋"
    exit 0
  fi
  sleep $(( i * 5 ))
done
echo "push 실패 (자세한 내용은 비공개 로그)"
exit 1
