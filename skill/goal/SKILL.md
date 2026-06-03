---
name: goal
description: brief.md(또는 지정한 단일 명세 파일)에 정리된 작업을 한 번에 끝까지 구현한다. 사용자가 "goal", "brief 실행", "이 brief대로 만들어줘", "발주", "brief.md 구현해줘"라고 하거나, 작성해 둔 brief를 바탕으로 실제 구현을 시작할 때 사용한다.
---

# goal — brief 한 방 발주

`brief.md` 에 정리된 작업 명세를 읽고, 그 내용을 **한 번의 작업으로 구체적으로 구현**한다.
mdlive 창에서 핑퐁으로 다듬어 완성한 brief 를 실제 코드/결과물로 옮기는 단계다.

## 입력

- 기본: 현재 작업 디렉토리의 `brief.md`
- 사용자가 다른 파일을 지정하면 그 파일을 쓴다 (예: "goal docs/feature-x.md")

## brief 구조 (5섹션)

- **Goal** — 무엇을, 왜
- **Context** — 관련 파일/제약 (기존 프로젝트에 추가 시)
- **Requirements** — 구현할 항목 체크리스트
- **Out of scope** — 건드리지 말 것
- **Acceptance criteria** — 검증 가능한 완료 기준

## 실행 규칙

1. brief 를 **끝까지** 읽는다. 일부만 보고 시작하지 않는다.
2. **Requirements 를 전부** 구현하고 **Acceptance criteria 를 모두 만족**시키는 것을 목표로 한다.
3. **Out of scope 는 건드리지 않는다.** 범위를 임의로 넓히지 않는다.
4. 모호하거나 정보가 빠진 부분은 **추측을 명시한다** — 합리적 가정을 세워 진행하되,
   그 가정을 작업 시작 시 한 줄로 요약해 사용자에게 알린다.
   단, 가정이 결과를 크게 좌우하면(아키텍처 선택 등) 진행 전에 먼저 확인한다.
5. 작업이 끝나면 Acceptance criteria 각 항목을 **충족 여부와 함께** 보고한다.

## brief 가 비어 있거나 부실하면

- 핵심 섹션(Goal / Requirements / Acceptance criteria)이 비어 있으면 바로 구현하지 않는다.
- 먼저 brief 를 채우도록 돕고, "mdlive 로 열어 실시간으로 보면서 다듬자"고 안내한다
  (`mdlive brief.md --watch`).
