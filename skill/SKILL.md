---
name: mdlive
description: 마크다운(.md) 또는 HTML 파일을 macOS 네이티브 창으로 즉시, 그리고 실시간으로 미리보기한다. AI 에이전트(Claude Code, Codex 등)가 문서를 써 내려가는 동안 글이 채워지는 것을 라이브로 보여준다. 사용자가 "미리보기", "preview", "mdlive", "창으로 열어줘", "렌더링해서 보여줘", "실시간으로 보면서 고치자"라고 하거나, 문서/리포트/리드미를 만든 뒤 결과를 바로 눈으로 확인하고 싶을 때 사용한다.
---

# mdlive — 마크다운/HTML 실시간 미리보기

`.md` / `.html` 파일을 WKWebView 기반 macOS 창으로 띄워 GitHub 스타일
(다크모드·코드 하이라이팅 포함)로 보여준다. `--watch` 를 주면 파일이 바뀔 때마다
**전체 리로드 없이 본문만 교체**해, 글이 써지는 과정을 스트리밍처럼 보여준다.

## 사용 조건

- macOS 13+, Swift 6 / Xcode 26+ 에서 빌드
- 에이전트와 무관하게 동작한다(파일을 쓰기만 하면 됨)

## 실행 방법

```bash
# 최초 1회 빌드
swift build -c release

# 미리보기
.build/release/mdlive <파일경로>

# 라이브(파일이 바뀌면 실시간 갱신) — 문서를 계속 고칠 거면 이걸 쓴다
.build/release/mdlive <파일경로> --watch

# 한글 문서는 한글 최적화 스타일 권장
.build/release/mdlive <파일경로> --style korean --watch
```

스타일: `--style github`(기본) / `korean`(한글 최적화) / `sepia`(따뜻한 읽기 테마).
**한글 문서를 보여줄 때는 `--style korean` 을 붙인다.**

전역 설치 시:

```bash
cp .build/release/mdlive /usr/local/bin/
mdlive report.md --watch
```

## 동작 규칙

- `.html` / `.htm` → 파일 그대로 로드(상대 경로 리소스 접근 허용).
- 그 외(`.md`, `.markdown` 등) → 마크다운으로 렌더링.
- `--watch` → 수정 시각을 폴링해 변경 시 본문을 in-place 로 갱신.
  사용자가 "보면서 고칠 거야" / "실시간" 의도를 보이면 `--watch` 를 붙인다.

## 권장 흐름

문서를 만들어 사용자에게 보여줄 때:

1. 결과를 파일로 쓴다.
2. `mdlive <파일> --watch` 를 백그라운드로 실행한다.
3. 이후 수정 사항을 같은 파일에 덮어쓰면 창이 자동으로 갱신된다.

## 자동 실행(선택)

매번 명령어를 칠 필요 없이, Claude Code / Codex 가 문서를 쓰면 창이 자동으로
뜨도록 연동할 수 있다. 저장소의 `integrations/` 디렉토리 참고:

- `integrations/claude-code/` — PostToolUse 훅
- `integrations/codex/` — notify 훅
