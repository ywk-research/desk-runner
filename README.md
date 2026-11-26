# desk-runner

Desk Notes 작업을 GitHub Actions에서 돌리는 실행용 저장소예요. 코드와 결과물은 비공개 저장소에 있고, 여기에는 실행 설정만 있어요.

- 실행할 때 비공개 저장소를 받아 명령을 돌리고, 결과는 그 저장소에 바로 커밋해요. 여기에는 아무 데이터도 남지 않아요.
- 명령 출력은 이 저장소의 실행 로그에 찍지 않고 비공개 저장소의 `runner-logs` 브랜치에 올려요.
- 아티팩트는 쓰지 않고, 캐시에는 SEC 공시 원문(공개 자료)만 넣어요.

## 워크플로

| 파일 | 하는 일 |
|---|---|
| `run.yml` | 수동 실행. 대상 저장소·브랜치·명령·커밋 경로를 받아 실행 |
| `signals-daily.yml` | signals 매일 업데이트(평일 한국시간 07:30) |

## 필요한 Secrets

- `PRIVATE_REPO_TOKEN`: fine-grained 토큰. 대상 저장소 signals, desk-private / 권한 Contents 읽기·쓰기, Actions 읽기
- `SEC_USER_AGENT`: SEC EDGAR 요청용 연락처

## 규칙

- 모든 워크플로에 `concurrency`와 `timeout-minutes`를 둔다.
- 명령 출력을 공개 로그에 찍지 않는다(`scripts/quiet.sh`로 감싼다). `set -x`, `cat`, `echo`로 데이터나 결과를 찍지 않는다.
- `pull_request`·`push` 트리거를 걸지 않는다(외부 PR이 Secrets 쪽 코드를 돌리지 못하게).
- `actions/upload-artifact`를 쓰지 않는다(공개 저장소의 아티팩트는 누구나 받을 수 있다).
- 공개 저장소의 예약 실행은 60일 동안 커밋이 없으면 GitHub이 꺼요. 꺼지면 Actions 탭에서 다시 켜요.
