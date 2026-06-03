#!/usr/bin/env bash
#
# Codex CLI notify 훅 — Codex 턴이 끝날 때마다, 최근에 수정된
# .md/.html 문서를 찾아 mdlive 라이브 미리보기로 띄운다.
#
# Codex 는 Claude Code 와 달리 "어떤 파일을 썼는지"를 훅에 주지 않으므로,
# 작업 디렉토리에서 최근(기본 60초) 변경된 문서를 추정해 연다.
#
# 설치: integrations/codex/README.md 참고.

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
opener="$here/../mdlive-open.sh"

# 어디서 문서를 찾을지 (기본: 현재 작업 디렉토리)
root="${MDLIVE_WATCH_ROOT:-$PWD}"
# 최근 몇 초 안에 바뀐 파일을 대상으로 볼지
window="${MDLIVE_RECENT_SECS:-60}"

# 최근 변경된 md/html 중 가장 최신 파일 하나
recent="$(
  find "$root" -type f \( -name '*.md' -o -name '*.markdown' -o -name '*.html' -o -name '*.htm' \) \
       -not -path '*/.git/*' -not -path '*/node_modules/*' \
       -newermt "-${window} seconds" 2>/dev/null \
  | xargs -I{} stat -f '%m %N' {} 2>/dev/null \
  | sort -rn | head -1 | cut -d' ' -f2-
)"

[ -n "${recent:-}" ] || exit 0
exec "$opener" "$recent"
