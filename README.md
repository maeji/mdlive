# mdlive

[![CI](https://github.com/maeji/mdlive/actions/workflows/ci.yml/badge.svg)](https://github.com/maeji/mdlive/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
![Platform](https://img.shields.io/badge/platform-macOS%2013%2B-blue)
![Swift](https://img.shields.io/badge/Swift-6-orange?logo=swift)

> AI 에이전트가 만든 마크다운·HTML을 **macOS 창에서 실시간으로** 미리보는 경량 도구
> — Claude Code, Codex, 그리고 마크다운을 파일로 쓰는 모든 도구와 함께.

<p align="center">
  <img src="assets/screenshot-rendering.png" alt="mdlive 렌더링 화면 — Mermaid 다이어그램과 코드 하이라이팅" width="720">
</p>

터미널에서 AI와 문서를 만들다 보면, 결과를 눈으로 확인하려고 매번 파일을 다른
앱으로 열게 됩니다. mdlive 는 그 과정을 한 줄로 줄이고, 한발 더 나아가
**에이전트가 글을 써 내려가는 동안 그 내용이 창에서 실시간으로 채워지는 것**을
보여줍니다. Artifacts 같은 경험을, 로컬 터미널 워크플로 안에서.

Swift(AppKit + WebKit)가 창과 파일 감시를 맡고, 실제 렌더링은 WKWebView 안의
검증된 JS 라이브러리(marked.js · highlight.js · github-markdown-css)가 처리합니다.

## brief-first 워크플로 — 파일 하나로 에이전트에게 한 번에 발주

새 프로젝트를 시작하거나 기존 프로젝트에 기능을 추가할 때, 복잡한 세팅 없이
**`brief.md` 파일 하나**에 만들 것을 정리합니다. mdlive 창에서 실시간으로 보며
에이전트와 핑퐁으로 다듬은 뒤, `goal` 한 번으로 발주합니다.

```
brief.md 작성  ─▶  mdlive --watch 로 보며 핑퐁으로 다듬기  ─▶  goal 로 한 번에 발주
```

- **`templates/brief.md`** — 5섹션 경량 템플릿(Goal / Context / Requirements /
  Out of scope / Acceptance criteria). spec-kit·Kiro 같은 다단계 의식 없이 한 화면.
- **`goal` skill** — 완성된 brief 를 Claude Code / Codex 가 끝까지 읽고 한 번에 구현.
  Requirements 를 전부 만족시키고 Out of scope 는 건드리지 않습니다.

<p align="center">
  <img src="assets/screenshot-brief.png" alt="mdlive 로 본 brief.md — Goal·Requirements·Out of scope·Acceptance criteria 5섹션" width="720">
</p>

> 무거운 spec 프레임워크와 raw 바이브코딩 **사이의 가벼운 중간지대**를 노립니다.
> 창 안에서 섹션을 골라 에이전트로 되보내는 인터랙티브 다듬기와 "발주 준비됨"
> 완성도 게이트는 로드맵에 있습니다(아래 참고).

## 특징

- 🔴 **실시간 스트리밍 렌더링** — 파일이 바뀌면 전체 리로드 없이 본문만 교체.
  깜빡임 없이 글이 채워지고, 하단에 있으면 자동으로 따라 내려갑니다(스트리밍 커서 포함)
- 📝 **brief-first 워크플로** — `brief.md` 하나를 실시간으로 다듬고 `goal` 로 한 번에 발주 (위 참고)
- 📄 **Markdown → GitHub 스타일 렌더링** (GFM, 표, 인용 등)
- 🎨 **코드 신택스 하이라이팅** (highlight.js)
- 📊 **Mermaid 다이어그램** — ` ```mermaid ` 코드 블록을 다이어그램으로 렌더
- 🧮 **KaTeX 수식** — `$...$` / `$$...$$` 수식 렌더 (폰트까지 임베딩, 오프라인)
- 🇰🇷 **렌더링 스타일 선택** — `--style github|korean|sepia`. `korean` 은 한글 글꼴·행간·`word-break: keep-all` 로 한글 가독성 최적화
- 📤 **내보내기 / 인쇄** — PDF · 자체완결 HTML · 인쇄 (⌘E / ⌘⇧E / ⌘P)
- 🔍 **줌 · 테마 토글** — ⌘+/⌘-/⌘0, ⌘T(자동/라이트/다크)
- 🌗 **다크모드 자동 대응** (`prefers-color-scheme`)
- 🧩 **에이전트 자동 연동** — Claude Code 훅 / Codex notify 로 "쓰면 자동으로 뜸"
- 🔌 **완전 오프라인** — 렌더링용 JS/CSS를 모두 번들에 동봉. 인터넷 불필요
- 🪶 **외부 패키지 의존 0** — 순수 Swift 표준 프레임워크만 사용

## 요구 사항

- macOS 13+
- Swift 6 / Xcode 26+
- (인터넷 연결 불필요 — 모든 렌더링 자산이 앱에 포함됨)

## 설치 & 사용

```bash
git clone <repo-url>
cd mdlive
swift build -c release

# 미리보기
.build/release/mdlive Examples/sample.md

# 라이브(실시간 갱신)
.build/release/mdlive Examples/sample.md --watch
```

전역 설치:

```bash
cp .build/release/mdlive /usr/local/bin/
mdlive report.md --watch
```

### 옵션

| 옵션 | 설명 |
|------|------|
| `<file>` | 미리볼 `.md` / `.markdown` / `.html` / `.htm` 파일 |
| `-w`, `--watch` | 파일 변경 시 실시간 갱신 |
| `-s`, `--style <name>` | 렌더링 스타일: `github`(기본) · `korean` · `sepia` |
| `-h`, `--help` | 도움말 |

#### 스타일

| 스타일 | 설명 |
|--------|------|
| `github` | GitHub 기본 (영문 기준) |
| `korean` | 한글 최적화 — Apple SD Gothic Neo 글꼴, 넉넉한 행간, `word-break: keep-all` 로 어절 단위 줄바꿈 |
| `sepia` | 따뜻한 종이색 읽기 테마 (한글 글꼴 적용, 라이트/다크 모두 대응) |

```bash
mdlive 문서.md --style korean --watch    # 한글 문서 추천
```

### 단축키

| 단축키 | 동작 |
|--------|------|
| `⌘E` / `⌘⇧E` | PDF / HTML 로 내보내기 |
| `⌘P` | 인쇄 |
| `⌘+` / `⌘-` / `⌘0` | 줌 인 / 아웃 / 원래 크기 |
| `⌘T` | 테마 전환 (자동 → 라이트 → 다크) |

## AI 에이전트와 함께 쓰기

mdlive 는 에이전트와 무관하게 동작합니다 — **누가 파일을 쓰든** `--watch` 가
변경을 감지합니다. 매번 명령어를 칠 필요 없이 자동으로 띄우려면 `integrations/`:

| 에이전트 | 연동 방식 | 가이드 |
|----------|-----------|--------|
| **Claude Code** | PostToolUse 훅 (Write/Edit 시 자동) | [integrations/claude-code](integrations/claude-code/) |
| **Codex CLI** | notify 훅 / `--watch` | [integrations/codex](integrations/codex/) |
| 그 외 | `mdlive <file> --watch` | — |

Claude Code Skill 로도 쓸 수 있습니다. `skill/` 의 두 스킬을 스킬 디렉토리에 두면,
"이거 미리보기로 보여줘"에 mdlive 를, "이 brief 대로 만들어줘"에 goal 을 호출합니다.

```
~/.claude/skills/mdlive/SKILL.md   # 실시간 미리보기
~/.claude/skills/goal/SKILL.md     # brief.md 를 끝까지 읽고 한 번에 구현
```

## 구조

```
mdlive/
├── Package.swift
├── Sources/mdlive/
│   ├── main.swift                # CLI 인자 파싱 / 진입점
│   ├── PreviewAppDelegate.swift  # 창 + 메뉴 + 내보내기/줌/테마 + 파일 감시
│   ├── FileWatcher.swift         # mtime 폴링 기반 변경 감지
│   ├── HTMLTemplate.swift        # 렌더링 셸 + window.__render 주입 지점
│   ├── Style.swift               # 렌더링 스타일(github/korean/sepia)
│   ├── Assets.swift              # 번들 동봉 JS/CSS 로더 (오프라인)
│   └── Resources/                # marked · highlight.js · mermaid · KaTeX(폰트 임베딩) · github-markdown-css
├── templates/brief.md            # brief-first 워크플로용 단일 파일 템플릿
├── skill/
│   ├── mdlive/SKILL.md           # 실시간 미리보기 skill
│   └── goal/SKILL.md             # brief 한 방 발주 skill
├── integrations/
│   ├── mdlive-open.sh            # 공통 런처(중복 창 방지)
│   ├── claude-code/              # Claude Code 훅
│   └── codex/                    # Codex 훅
└── Examples/                     # sample.md, brief.md, features.md, math.md, korean.md
```

## 동작 원리

1. **셸 + 주입 구조** — 마크다운 본문을 HTML 에 인라인하지 않습니다. 빈 셸을
   먼저 로드하고, Swift 가 파일이 바뀔 때마다 `window.__render(src)` 를
   호출(evaluateJavaScript)해 **본문 DOM 만 교체**합니다. 그래서 스트리밍 중에도
   페이지가 리로드되지 않고, 스크롤 위치가 유지됩니다.
2. **스크롤 스틱** — 갱신 시 사용자가 거의 바닥에 있으면 자동으로 바닥에 붙여
   둡니다(채팅처럼 새 내용을 따라감). 위로 올려둔 상태면 위치를 보존합니다.
3. **견고한 watch** — 파일 수정 시각을 0.4초 간격으로 폴링합니다. 에디터의
   원자적 저장(rename)에도 강하도록 vnode 이벤트 대신 mtime 폴링을 씁니다.
4. **안전한 주입** — 본문 문자열은 `JSONEncoder` 로 JS 리터럴로 인코딩해
   따옴표·역슬래시·개행 이스케이프 문제를 원천 차단합니다.

## 로드맵

- [x] JS/CSS 오프라인 번들링 (CDN 의존 제거)
- [x] Mermaid 다이어그램 렌더링
- [x] KaTeX 수식 렌더링 (폰트 base64 임베딩으로 오프라인)
- [x] PDF / HTML 내보내기 · 인쇄 · 줌 · 테마 토글
- [x] brief-first 워크플로 (단일 `brief.md` 템플릿 + `goal` skill)
- [ ] brief 완성도 게이트 — "발주 준비됨" 점검(누락 섹션·검증 불가능한 기준 표시)
- [ ] 미리보기에서 섹션 선택 → 에이전트로 되보내기 (핑퐁 자동화)
- [ ] brief 완성도 LLM 분석 (모호성·누락·충돌 비평)
- [ ] 메뉴바 상주 모드 / 멀티 탭

## 라이선스

MIT. 동봉된 서드파티 렌더링 자산의 라이선스는 [THIRD_PARTY_LICENSES.md](THIRD_PARTY_LICENSES.md) 참고.
