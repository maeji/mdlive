#!/usr/bin/env bash
#
# Claude Code PostToolUse 훅 — Write/Edit 로 .md/.html 파일을 만들거나 고치면
# 자동으로 mdlive 라이브 미리보기를 띄운다.
#
# Claude Code 는 훅 입력(JSON)을 stdin 으로 넘긴다. 그 안의
# tool_input.file_path 를 꺼내 mdlive-open.sh 로 전달한다.
#
# 설치: 아래 settings.json 예시 참고 (integrations/claude-code/README.md).

set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
opener="$here/../mdlive-open.sh"

input="$(cat)"

# jq 가 있으면 jq, 없으면 python3 로 file_path 추출
if command -v jq >/dev/null 2>&1; then
  file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
else
  file="$(printf '%s' "$input" | python3 -c \
    'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("file_path",""))' \
    2>/dev/null || true)"
fi

[ -n "${file:-}" ] || exit 0
exec "$opener" "$file"
