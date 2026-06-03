#!/usr/bin/env bash
#
# mdlive-open.sh — 주어진 파일을 mdlive 라이브 미리보기로 (중복 없이) 띄운다.
#
# 에이전트 훅(Claude Code / Codex 등)에서 공통으로 호출하는 얇은 런처.
# 같은 파일을 이미 --watch 로 보고 있으면 새 창을 띄우지 않는다(이미 자동 갱신되므로).
#
# 사용법:  mdlive-open.sh <파일경로>
#
# 환경변수:
#   MDLIVE_BIN  mdlive 실행 파일 경로 (기본: PATH 의 mdlive)

set -euo pipefail

file="${1:-}"
[ -n "$file" ] || exit 0
[ -f "$file" ] || exit 0

# 마크다운/HTML 만 대상으로
case "$file" in
  *.md|*.markdown|*.html|*.htm) ;;
  *) exit 0 ;;
esac

# 절대경로로 정규화
file="$(cd "$(dirname "$file")" && pwd)/$(basename "$file")"

bin="${MDLIVE_BIN:-mdlive}"
command -v "$bin" >/dev/null 2>&1 || { echo "mdlive 를 찾을 수 없습니다 (PATH 또는 MDLIVE_BIN 확인)" >&2; exit 0; }

# 이미 같은 파일을 watch 중이면 그대로 둔다 (창이 알아서 갱신됨)
if pgrep -f "mdlive .*$file" >/dev/null 2>&1; then
  exit 0
fi

nohup "$bin" "$file" --watch >/dev/null 2>&1 &
exit 0
