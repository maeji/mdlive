import AppKit

// MARK: - CLI 인자 파싱

struct Options {
    var path: String
    var watch: Bool
    var style: Style
}

func printUsage() {
    let exe = (CommandLine.arguments.first as NSString?)?.lastPathComponent ?? "mdlive"
    print("""
    mdlive — 마크다운/HTML 을 macOS 창으로 실시간 미리보기

    USAGE:
        \(exe) <file> [options]

    ARGUMENTS:
        <file>              미리볼 마크다운(.md/.markdown) 또는 HTML(.html/.htm) 파일

    OPTIONS:
        -w, --watch         파일이 바뀌면 자동으로 갱신 (라이브 리로드)
        -s, --style <name>  렌더링 스타일 (기본: github)
                            사용 가능: \(Style.names)
                              github  GitHub 기본(영문 기준)
                              korean  한글 최적화(글꼴·행간·줄바꿈 조정)
                              sepia   따뜻한 종이색 읽기 테마(한글 글꼴)
        -h, --help          이 도움말 출력
    """)
}

func parseOptions() -> Options? {
    var path: String?
    var watch = false
    var style: Style = .fallback

    var args = Array(CommandLine.arguments.dropFirst())
    var i = 0
    while i < args.count {
        let arg = args[i]
        switch arg {
        case "-h", "--help":
            printUsage()
            exit(0)
        case "-w", "--watch":
            watch = true
        case "-s", "--style":
            i += 1
            guard i < args.count else {
                FileHandle.standardError.write(Data("--style 에 값이 필요합니다.\n".utf8))
                return nil
            }
            guard let parsed = Style.parse(args[i]) else {
                FileHandle.standardError.write(Data("알 수 없는 스타일: \(args[i]) (사용 가능: \(Style.names))\n".utf8))
                return nil
            }
            style = parsed
        default:
            // --style=korean 형태 지원
            if arg.hasPrefix("--style=") {
                let value = String(arg.dropFirst("--style=".count))
                guard let parsed = Style.parse(value) else {
                    FileHandle.standardError.write(Data("알 수 없는 스타일: \(value) (사용 가능: \(Style.names))\n".utf8))
                    return nil
                }
                style = parsed
            } else if arg.hasPrefix("-") {
                FileHandle.standardError.write(Data("알 수 없는 옵션: \(arg)\n".utf8))
                return nil
            } else if path == nil {
                path = arg
            }
        }
        i += 1
    }

    guard let path else {
        FileHandle.standardError.write(Data("파일 경로가 필요합니다.\n".utf8))
        return nil
    }
    return Options(path: path, watch: watch, style: style)
}

// MARK: - 진입점

guard let options = parseOptions() else {
    printUsage()
    exit(64) // EX_USAGE
}

let url = URL(fileURLWithPath: options.path)
guard FileManager.default.fileExists(atPath: url.path) else {
    FileHandle.standardError.write(Data("파일을 찾을 수 없습니다: \(url.path)\n".utf8))
    exit(66) // EX_NOINPUT
}

let app = NSApplication.shared
let delegate = PreviewAppDelegate(fileURL: url.standardizedFileURL, watch: options.watch, style: options.style)
app.delegate = delegate
app.setActivationPolicy(.regular)
app.activate(ignoringOtherApps: true)
app.run()
