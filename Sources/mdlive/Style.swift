import Foundation

/// 렌더링 스타일(테마). `--style <name>` 으로 선택한다.
///
/// 기본 GitHub 스타일은 영문 기준이라 한글에서 행간·자간·줄바꿈이 어색할 수 있다.
/// `korean` 은 한글 본문에 맞춰 글꼴·행간·`word-break: keep-all` 등을 조정한다.
enum Style: String, CaseIterable {
    case github   // GitHub 기본(영문 기준)
    case korean   // 한글 최적화
    case sepia    // 따뜻한 종이색 읽기 테마(한글 글꼴 적용)

    static let fallback: Style = .github

    static func parse(_ raw: String) -> Style? {
        Style(rawValue: raw.lowercased())
    }

    static var names: String {
        allCases.map { $0.rawValue }.joined(separator: ", ")
    }

    /// 한글 가독성을 위한 글꼴 스택(macOS 기본 탑재 글꼴 우선).
    private static let koreanFontStack =
        "\"Apple SD Gothic Neo\", \"Pretendard\", \"Noto Sans KR\", " +
        "-apple-system, BlinkMacSystemFont, \"Segoe UI\", sans-serif"

    /// 기본 셸 CSS 뒤에 덧붙여 적용할 오버라이드. github 는 오버라이드가 없다.
    var css: String {
        switch self {
        case .github:
            return ""

        case .korean:
            return """
            .markdown-body {
              font-family: \(Self.koreanFontStack);
              font-size: 16.5px;
              line-height: 1.85;
              letter-spacing: -0.003em;
              word-break: keep-all;        /* 한글 단어가 어색하게 잘리지 않도록 */
              overflow-wrap: break-word;
            }
            .markdown-body p,
            .markdown-body li { line-height: 1.9; }
            .markdown-body h1,
            .markdown-body h2,
            .markdown-body h3,
            .markdown-body h4 { letter-spacing: -0.02em; line-height: 1.45; }
            /* 코드는 등폭 글꼴 유지(자간 조정 제외) */
            .markdown-body code,
            .markdown-body pre { font-family: "SF Mono", ui-monospace, Menlo, monospace; letter-spacing: 0; }
            """

        case .sepia:
            return """
            body { background: #f4ecd8 !important; }
            .markdown-body {
              color: #43342a;
              font-family: \(Self.koreanFontStack);
              font-size: 16.5px;
              line-height: 1.85;
              letter-spacing: -0.003em;
              word-break: keep-all;
              overflow-wrap: break-word;
              max-width: 740px;
            }
            .markdown-body a { color: #8a5a2b; }
            .markdown-body h1, .markdown-body h2 { border-bottom-color: #d8c8a8; }
            .markdown-body pre, .markdown-body code { background: #ece0c8 !important; }
            .markdown-body blockquote { color: #6b5a44; border-left-color: #cdbb98; }
            .markdown-body code, .markdown-body pre { font-family: "SF Mono", ui-monospace, Menlo, monospace; }
            @media (prefers-color-scheme: dark) {
              body { background: #262019 !important; }
              .markdown-body { color: #e7d9c0; }
              .markdown-body pre, .markdown-body code { background: #332b20 !important; }
              .markdown-body blockquote { color: #b8a888; border-left-color: #5a4d38; }
            }
            """
        }
    }
}
