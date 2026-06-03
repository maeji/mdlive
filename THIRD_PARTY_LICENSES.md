# 서드파티 라이선스

mdlive 는 오프라인 렌더링을 위해 아래 오픈소스 자산을 `Sources/mdlive/Resources/`
에 동봉(vendoring)합니다. 각 자산의 저작권과 라이선스는 다음과 같습니다.

## marked

- 파일: `marked.min.js`
- 출처: https://github.com/markedjs/marked
- 라이선스: MIT
- © 2018+, MarkedJS / 2011-2018, Christopher Jeffrey

## highlight.js

- 파일: `highlight.min.js`, `hljs-github.min.css`, `hljs-github-dark.min.css`
- 출처: https://github.com/highlightjs/highlight.js
- 라이선스: BSD-3-Clause
- © 2006, Ivan Sagalaev

## mermaid

- 파일: `mermaid.min.js`
- 출처: https://github.com/mermaid-js/mermaid
- 라이선스: MIT
- © 2014-2022, Knut Sveidqvist

## KaTeX

- 파일: `katex.min.js`, `auto-render.min.js`, `katex.min.css`(woff2 폰트 base64 임베딩)
- 출처: https://github.com/KaTeX/KaTeX
- 라이선스: MIT
- © 2013-2020, Khan Academy 외
- 비고: `katex.min.css` 는 오프라인 동작을 위해 woff2 폰트를 data URI 로 임베딩하도록
  가공했습니다(woff/ttf 상대경로 참조는 제거). 폰트 자체의 라이선스도 MIT(SIL OFL 아님)입니다.

## github-markdown-css

- 파일: `github-markdown.min.css`
- 출처: https://github.com/sindresorhus/github-markdown-css
- 라이선스: MIT
- © Sindre Sorhus

---

각 라이선스 전문은 위 저장소를 참고하세요. 자산을 갱신할 때는 동일 라이선스의
동일 프로젝트에서 받아 이 문서를 함께 업데이트하세요.
