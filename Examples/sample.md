# mdlive 데모

에이전트가 만든 마크다운을 **바로 창으로** 실시간 미리보는 도구입니다.

## 기능

- 마크다운 → GitHub 스타일 렌더링
- 코드 신택스 하이라이팅
- 다크모드 자동 대응
- `--watch` 라이브 리로드

## 코드 예시

```swift
let app = NSApplication.shared
app.setActivationPolicy(.regular)
app.run()
```

```python
def hello(name: str) -> str:
    return f"안녕, {name}!"
```

## 표

| 항목 | 담당 |
|------|------|
| 창/감시 | Swift (AppKit + WebKit) |
| 렌더링 | marked.js + highlight.js |

> 인용문도 잘 나옵니다.
