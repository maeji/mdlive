# mdlive — 프로젝트 컨텍스트 (기여자 / 에이전트용)

> 이 파일은 코드를 만지는 사람(과 에이전트)을 위한 설계·구현 컨텍스트다.
> Claude Code 같은 에이전트가 이 폴더를 열면 자동으로 읽고, 일관된 방향으로 작업하도록 돕는다.

## 한 줄 요약

AI 에이전트(Claude Code, Codex 등)가 만든 마크다운·HTML을 **macOS 창에서 실시간으로**
미리보는 Swift 도구.

## 정체성 / 컨셉

- 이름: **mdlive** (초기엔 `claude-preview` 였다가 멀티 에이전트 지향으로 개명)
- 핵심 차별점: 단순 뷰어가 아니라 **에이전트가 글을 써 내려가는 동안 실시간 스트리밍 렌더링**
  ("Artifacts 같은 경험을 로컬 터미널 워크플로 안에서")
- 에이전트 무관(agent-agnostic): 누가 파일을 쓰든 `--watch` 가 감지

## 기술 스택 / 아키텍처

- **Swift 6 / macOS 13+ / SwiftPM 실행 파일** (Xcode 26 환경에서 개발)
- 외부 Swift 패키지 의존 **0** — AppKit + WebKit 표준 프레임워크만
- **역할 분리**: Swift = 창·메뉴·파일감시·플러밍 / WKWebView 안의 JS = 실제 렌더링
- 렌더링 라이브러리는 모두 **번들에 동봉(오프라인)**, CDN 의존 없음

### 핵심 설계 — 스트리밍 렌더링

- 마크다운 본문을 HTML 에 인라인하지 **않는다**. 빈 셸(`HTMLTemplate.shell`)을 먼저 로드하고,
  Swift 가 파일 변경 시마다 `window.__render(src, streaming)` 를 `evaluateJavaScript` 로 호출해
  **본문 DOM 만 교체**. → 전체 리로드 없음, 깜빡임 없음, 스크롤 위치 유지.
- 본문 문자열은 `JSONEncoder` 로 JS 리터럴 인코딩해 안전하게 주입.
- 스크롤이 거의 바닥이면 갱신 후에도 바닥에 붙임(스트리밍 UX) + 깜빡이는 커서, 1.2초 무변경 시 끔.

## 파일 구조

```
mdlive/
├── Package.swift                 # SwiftPM, resources: [.copy("Resources")]
├── CLAUDE.md                     # ← 이 파일
├── README.md                     # 사용자용 문서
├── LICENSE                       # MIT
├── THIRD_PARTY_LICENSES.md       # vendoring 라이브러리 라이선스 고지
├── Sources/mdlive/
│   ├── main.swift                # CLI 인자 파싱(--watch, --style) / 진입점
│   ├── PreviewAppDelegate.swift  # 창 + 메뉴 + 내보내기/줌/테마 + 파일감시 + __render 주입
│   ├── FileWatcher.swift         # mtime 폴링(0.4s) 기반 변경 감지
│   ├── HTMLTemplate.swift        # 렌더링 셸 생성 + window.__render 정의
│   ├── Style.swift               # 렌더링 스타일(github/korean/sepia) CSS
│   ├── Assets.swift              # 번들 동봉 JS/CSS 로더 (static let, scriptSafe 이스케이프)
│   └── Resources/                # vendoring 자산 (총 ~4MB)
│       ├── marked.min.js              # Markdown→HTML (MIT)
│       ├── highlight.min.js + 2 css   # 코드 하이라이팅 (BSD-3)
│       ├── mermaid.min.js             # 다이어그램 (MIT, 3.2MB)
│       ├── katex.min.js + auto-render.min.js
│       └── katex.min.css              # ★ woff2 폰트 20개를 base64 임베딩한 자체완결 CSS (MIT)
├── skill/SKILL.md                # Claude Code Skill 정의
├── integrations/
│   ├── mdlive-open.sh            # 공통 런처(중복 창 방지, pgrep 체크)
│   ├── claude-code/              # PostToolUse 훅 (Write/Edit→자동 실행) + README
│   └── codex/                    # notify 훅(최근 수정 문서 추정) + README
└── Examples/                     # sample.md, features.md(mermaid), math.md(katex), korean.md
```

## 구현 완료된 기능

- [x] 마크다운(GFM) → GitHub 스타일 렌더링 + 다크모드 자동
- [x] 코드 신택스 하이라이팅 (highlight.js)
- [x] **실시간 스트리밍 렌더링** (in-place 갱신, 스크롤 스틱, 커서)
- [x] `--watch` 라이브 리로드
- [x] **Mermaid 다이어그램** (` ```mermaid `, suppressErrorRendering 으로 스트리밍 중 에러 억제)
- [x] **KaTeX 수식** ($...$, $$...$$, \\(...\\), \\[...\\]) — 폰트 base64 임베딩으로 완전 오프라인
- [x] **내보내기/인쇄** — PDF(⌘E, WKWebView.createPDF) / 자체완결 HTML(⌘⇧E, outerHTML) / 인쇄(⌘P)
- [x] **줌** ⌘+/⌘-/⌘0 (pageZoom), **테마 토글** ⌘T (webView.appearance 로 auto/light/dark)
- [x] **렌더링 스타일** `--style github|korean|sepia` — korean 은 Apple SD Gothic Neo +
      행간 1.85 + `word-break: keep-all` 로 한글 가독성 최적화
- [x] **멀티 에이전트 연동** — Claude Code 훅 / Codex notify / 공용 `--watch`
- [x] **완전 오프라인** — 모든 자산 번들 동봉, 외부 URL 0 (vendoring 파일 내부 주석 제외)

## 빌드 / 실행 / 테스트

```bash
swift build                              # 디버그
swift build -c release                   # 릴리스
.build/debug/mdlive Examples/korean.md --style korean --watch
.build/release/mdlive <file> [--watch] [--style github|korean|sepia]
```

### 스크린샷 검증 트릭 (개발 중 시각 확인용)

WKWebView 렌더 결과를 눈으로 확인할 때 사용한 방법:
```bash
nohup .build/debug/mdlive Examples/math.md >/tmp/cp.log 2>&1 &
P=$!; sleep 4
osascript -e "tell application \"System Events\" to set frontmost of (first process whose unix id is $P) to true"
sleep 1.5
screencapture -o -x /tmp/shot.png
kill $P
# 그 후 /tmp/shot.png 을 Read 로 확인
```
- 창이 풀스크린 터미널 뒤/다른 Space 에 떠서 안 잡힐 때가 있다 → 대기시간 늘리고 frontmost 재시도.
- 시스템 python3 에 Quartz 모듈 없음 → CGWindowList 윈도우 직접캡처는 안 됨.

## 중요한 설계 결정 / 함정 (재현 시 주의)

1. **Swift 6 strict concurrency**: `FileWatcher.onChange` 는 `@Sendable`, 콜백은 메인큐로 디스패치 후
   `MainActor.assumeIsolated` 안에서 호출. static 가변 전역 금지(→ `Assets` 는 `static let` 만).
2. **`</script` 이스케이프**: 번들 JS 를 `<script>` 에 인라인하므로 `Assets.scriptSafe` 가
   `</script` → `<\/script` 치환(현재 자산엔 0건이지만 버전 변경 대비).
3. **KaTeX 폰트 오프라인화**: `katex.min.css` 의 `url(fonts/*.woff2)` 를 base64 data URI 로 치환하고
   woff/ttf 상대경로 참조는 제거함. 폰트 갱신 시 `/tmp/katex-build` 에서 했던 python 스크립트 재실행 필요
   (다운로드→base64 임베딩). 결과 CSS ~359KB.
4. **baseURL**: 마크다운 렌더 시 `loadHTMLString(baseURL: 파일디렉토리)` — 상대경로 이미지용.
   그래서 모든 CSS/JS 는 반드시 인라인이어야 함(외부 파일 참조 불가).
5. **테마 토글**은 CSS 가 아니라 `webView.appearance` 전환으로 구현 → media-query CSS 전부 따라옴.
   단 mermaid 테마는 초기화 시점 고정이라 ⌘T 에 즉시 반응하지 않음(알려진 제약).

## 다음 할 일 (로드맵)

- [ ] GitHub Actions CI(swift build/test)
- [ ] README 에 스크린샷/GIF 추가 (star 유입에 중요)
- [ ] 메뉴바 상주 모드 / 멀티 탭
- [ ] 미리보기에서 문단 선택 → 에이전트로 피드백 되보내기
- [ ] (선택) 기본 스타일에 한글 자동 감지, 스타일 ⌘ 단축키 전환

## 기여 메모

- `.build/` 는 커밋 제외(.gitignore 에 있음). 단 `Sources/mdlive/Resources/` 의 vendoring 자산은
  **반드시 포함**해야 오프라인 동작이 보장된다 — 빼면 렌더링이 깨진다.
- 권장 빌드 환경: macOS 13+, Swift 6, Xcode 26+.
- 코드/문서 주 언어는 한국어 주석을 일부 사용하지만, 기여 PR 은 한국어/영어 모두 환영.
