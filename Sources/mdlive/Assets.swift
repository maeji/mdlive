import Foundation

/// 번들에 동봉된 렌더링 에셋(JS/CSS)을 읽어온다.
///
/// 모든 자원을 앱 번들에 포함해 인라인하므로 **인터넷 연결 없이** 동작한다.
/// (marked, highlight.js, github-markdown-css — 라이선스는 THIRD_PARTY_LICENSES.md)
enum Assets {

    // 각 자원은 static let 으로 최초 1회만 lazy 로 읽힌다.
    static let markedJS          = scriptSafe(load("marked.min", "js"))
    static let highlightJS        = scriptSafe(load("highlight.min", "js"))
    static let mermaidJS          = scriptSafe(load("mermaid.min", "js"))
    static let katexJS            = scriptSafe(load("katex.min", "js"))
    static let katexAutoRenderJS  = scriptSafe(load("auto-render.min", "js"))
    static let highlightLightCSS  = load("hljs-github.min", "css")
    static let highlightDarkCSS   = load("hljs-github-dark.min", "css")
    static let githubMarkdownCSS  = load("github-markdown.min", "css")
    // 폰트(woff2)가 base64 data URI 로 임베딩된 자체완결 CSS
    static let katexCSS           = load("katex.min", "css")

    /// `<script>` 블록에 인라인할 JS 안의 `</script` 시퀀스가 블록을 조기 종료시키지
    /// 않도록 막는다. 문자열/정규식 리터럴 안에서 `<\/script` 는 `</script` 와 같다.
    private static func scriptSafe(_ js: String) -> String {
        js.replacingOccurrences(
            of: "</script",
            with: "<\\/script",
            options: .caseInsensitive
        )
    }

    private static func load(_ name: String, _ ext: String) -> String {
        guard let url = Bundle.module.url(forResource: name, withExtension: ext, subdirectory: "Resources"),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            // 번들 누락 시에도 앱이 죽지 않도록 빈 문자열로 폴백
            return ""
        }
        return text
    }
}
