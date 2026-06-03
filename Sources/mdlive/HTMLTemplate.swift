import Foundation

/// WKWebView 안에서 마크다운을 렌더링할 HTML 셸(shell)을 만든다.
///
/// 핵심 설계: 본문 텍스트를 HTML 에 인라인하지 않는다. 대신 셸은 비어 있고,
/// `window.__render(src)` 전역 함수를 노출한다. Swift 쪽에서 파일이 바뀔 때마다
/// 이 함수를 호출(evaluateJavaScript)해 **전체 페이지 리로드 없이 본문만 교체**한다.
/// → 스트리밍 중에도 깜빡임이 없고, 스크롤 위치가 유지된다.
///
/// 렌더링 라이브러리는 모두 번들에 동봉되어 인라인된다(오프라인 동작):
///   - marked            : Markdown → HTML (GFM)
///   - highlight.js      : 코드 블록 신택스 하이라이팅
///   - mermaid           : ```mermaid 코드 블록을 다이어그램으로 렌더
///   - KaTeX             : $...$ / $$...$$ 수식 렌더 (폰트까지 임베딩)
///   - github-markdown-css: GitHub 스타일 + 다크모드 자동 대응
enum HTMLTemplate {

    /// 본문 없는 렌더링 셸. 실제 내용은 Swift가 `__render` 로 주입한다.
    /// CSS/JS 는 외부 CDN 이 아니라 번들 리소스를 직접 인라인한다.
    /// `style` 의 오버라이드 CSS 는 기본 스타일 뒤에 적용된다.
    static func shell(style: Style = .github) -> String {
        return """
        <!DOCTYPE html>
        <html lang="ko">
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <style>\(Assets.githubMarkdownCSS)</style>
          <style media="(prefers-color-scheme: light)">\(Assets.highlightLightCSS)</style>
          <style media="(prefers-color-scheme: dark)">\(Assets.highlightDarkCSS)</style>
          <style>\(Assets.katexCSS)</style>
          <script>\(Assets.markedJS)</script>
          <script>\(Assets.highlightJS)</script>
          <script>\(Assets.mermaidJS)</script>
          <script>\(Assets.katexJS)</script>
          <script>\(Assets.katexAutoRenderJS)</script>
          <style>
            /* 본문 바깥(body) 배경을 GitHub canvas 색에 맞춰 좌우 흰 띠 제거 */
            body { margin: 0; background-color: #ffffff; }
            @media (prefers-color-scheme: dark) {
              body { background-color: #0d1117; }
            }
            .markdown-body {
              background-color: transparent;
              box-sizing: border-box;
              max-width: 820px;
              margin: 0 auto;
              padding: 32px 40px 80px;
            }
            @media (max-width: 640px) {
              .markdown-body { padding: 20px; }
            }
            /* 스트리밍 중 마지막 줄 끝에 깜빡이는 커서 */
            #content.streaming > :last-child::after {
              content: "▍";
              margin-left: 2px;
              opacity: 0.5;
              animation: mdlive-blink 1s steps(1) infinite;
            }
            @keyframes mdlive-blink { 50% { opacity: 0; } }
            /* Mermaid 다이어그램: 가운데 정렬, 배경 투명 */
            .mermaid {
              background: transparent !important;
              text-align: center;
              margin: 16px 0;
            }
            .mermaid svg { max-width: 100%; height: auto; }
          </style>
          <!-- 선택한 스타일(테마) 오버라이드 — 기본 스타일 뒤에 적용 -->
          <style>\(style.css)</style>
        </head>
        <body>
          <article class="markdown-body" id="content"></article>
          <script>
            (function () {
              const content = document.getElementById('content');
              let pending = null;       // 라이브러리 로드 전에 들어온 마지막 내용
              let libsReady = false;

              function libsLoaded() {
                return !!(window.marked && window.hljs);  // mermaid 는 선택
              }

              function setupMermaid() {
                if (!window.mermaid) return;
                const dark = window.matchMedia
                  && window.matchMedia('(prefers-color-scheme: dark)').matches;
                mermaid.initialize({
                  startOnLoad: false,
                  securityLevel: 'strict',
                  suppressErrorRendering: true,   // 스트리밍 중 미완성 다이어그램 에러박스 억제
                  theme: dark ? 'dark' : 'default'
                });
              }

              function doRender(src, streaming) {
                // 스크롤이 거의 바닥이면, 갱신 후에도 바닥에 붙여 둔다(스트리밍 UX)
                const stick = (window.innerHeight + window.scrollY)
                              >= (document.body.scrollHeight - 80);

                if (window.marked) {
                  content.innerHTML = marked.parse(src);
                } else {
                  content.innerHTML = '';
                  const pre = document.createElement('pre');
                  pre.textContent = src;
                  content.appendChild(pre);
                }

                // ```mermaid 코드 블록을 mermaid 가 처리할 수 있는 형태로 변환
                content.querySelectorAll('code.language-mermaid').forEach(function (code) {
                  const holder = document.createElement('pre');
                  holder.className = 'mermaid';
                  holder.textContent = code.textContent;
                  (code.closest('pre') || code).replaceWith(holder);
                });

                // mermaid 가 아닌 코드 블록만 하이라이팅
                if (window.hljs) {
                  content.querySelectorAll('pre:not(.mermaid) code').forEach(function (b) {
                    hljs.highlightElement(b);
                  });
                }

                // 다이어그램 렌더 (미완성/오류는 조용히 건너뜀)
                if (window.mermaid) {
                  const nodes = content.querySelectorAll('.mermaid');
                  if (nodes.length) {
                    try { mermaid.run({ nodes: nodes }); } catch (e) { /* streaming */ }
                  }
                }

                // 수식 렌더 ($...$, $$...$$, \\(...\\), \\[...\\])
                if (window.renderMathInElement) {
                  try {
                    renderMathInElement(content, {
                      delimiters: [
                        { left: "$$", right: "$$", display: true },
                        { left: "$",  right: "$",  display: false },
                        { left: "\\\\[", right: "\\\\]", display: true },
                        { left: "\\\\(", right: "\\\\)", display: false }
                      ],
                      throwOnError: false,
                      ignoredTags: ["script", "noscript", "style", "textarea", "pre", "code"]
                    });
                  } catch (e) { /* streaming */ }
                }

                content.classList.toggle('streaming', !!streaming);
                if (stick) window.scrollTo(0, document.body.scrollHeight);
              }

              // Swift가 호출하는 전역 진입점
              window.__render = function (src, streaming) {
                pending = { src: src, streaming: streaming };
                if (libsReady || libsLoaded()) {
                  libsReady = true;
                  doRender(src, streaming);
                }
              };

              // 번들 스크립트까지 모두 로드된 뒤 대기 중이던 내용을 그린다
              window.addEventListener('load', function () {
                setupMermaid();
                libsReady = libsLoaded();
                if (pending) doRender(pending.src, pending.streaming);
              });
            })();
          </script>
        </body>
        </html>
        """
    }
}
