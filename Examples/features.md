# mdlive 기능 데모

## Mermaid 다이어그램

```mermaid
flowchart LR
    A[파일 변경] --> B{확장자?}
    B -->|.md| C[marked 렌더]
    B -->|.html| D[그대로 로드]
    C --> E[highlight.js]
    C --> F[mermaid 다이어그램]
    E --> G[창에 표시]
    F --> G
```

## 시퀀스 다이어그램

```mermaid
sequenceDiagram
    Agent->>File: report.md 작성
    File-->>mdlive: 변경 감지(watch)
    mdlive->>Window: window.__render()
    Window-->>User: 실시간 표시
```

## 코드 하이라이팅

```swift
webView.createPDF(configuration: WKPDFConfiguration()) { result in
    if case .success(let data) = result { try? data.write(to: url) }
}
```

## 단축키

| 기능 | 단축키 |
|------|--------|
| PDF 내보내기 | ⌘E |
| HTML 내보내기 | ⌘⇧E |
| 인쇄 | ⌘P |
| 줌 인/아웃 | ⌘+ / ⌘- |
| 테마 전환 | ⌘T |
