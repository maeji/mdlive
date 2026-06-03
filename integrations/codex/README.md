# Codex CLI 연동

mdlive 는 에이전트와 무관하게 동작합니다 — 누가 파일을 쓰든 `--watch` 가
변경을 감지해 갱신하기 때문입니다. Codex 와는 두 가지 방법으로 붙일 수 있습니다.

## 방법 1 — 그냥 `--watch` (가장 단순, 권장)

출력할 파일을 미리 정해두고 mdlive 를 띄워둡니다. Codex 가 그 파일을 고치면
창이 실시간으로 갱신됩니다.

```bash
mdlive report.md --watch &
codex   # Codex 가 report.md 를 작성/수정 → 창에서 바로 보임
```

## 방법 2 — `notify` 훅으로 자동 실행

Codex 는 턴이 끝날 때 외부 프로그램을 호출하는 `notify` 설정을 제공합니다.
이를 이용해, 최근 변경된 문서를 자동으로 띄울 수 있습니다.

1. mdlive 빌드 후 PATH 에 설치하고, 스크립트에 실행 권한을 줍니다.

   ```bash
   swift build -c release && cp .build/release/mdlive /usr/local/bin/
   chmod +x integrations/mdlive-open.sh integrations/codex/mdlive-notify.sh
   ```

2. `~/.codex/config.toml` 에 notify 를 추가합니다.

   ```toml
   notify = ["/절대/경로/mdlive/integrations/codex/mdlive-notify.sh"]
   ```

### 동작

- Codex 턴이 끝나면 `mdlive-notify.sh` 가 실행됩니다.
- 작업 디렉토리에서 **최근 변경된** `.md`/`.html` 중 가장 최신 파일을 찾아 띄웁니다.
- 이미 그 파일을 보고 있으면 새 창을 띄우지 않습니다.

### 조정 가능한 환경변수

| 변수 | 기본값 | 설명 |
|------|--------|------|
| `MDLIVE_WATCH_ROOT` | 현재 작업 디렉토리 | 문서를 찾을 루트 |
| `MDLIVE_RECENT_SECS` | `60` | "최근 변경"으로 볼 시간(초) |
| `MDLIVE_BIN` | `mdlive` | mdlive 실행 파일 경로 |

> Codex 는 파일 경로를 훅에 직접 넘기지 않으므로, 방법 2 는 "최근 수정 파일"을
> 추정하는 방식입니다. 대상이 분명하다면 방법 1 이 더 정확합니다.
