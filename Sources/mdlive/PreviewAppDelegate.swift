import AppKit
import WebKit
import UniformTypeIdentifiers

/// 미리보기 창을 띄우고, 파일 변경을 감시해 내용을 실시간으로 갱신한다.
///
/// 마크다운은 페이지를 다시 로드하지 않고 `window.__render` 호출로 본문만 교체해
/// 스트리밍 중에도 깜빡임 없이 부드럽게 갱신된다. HTML 파일은 그대로 다시 로드한다.
final class PreviewAppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate {

    private enum Mode {
        case markdown
        case html
    }

    private let fileURL: URL
    private let watch: Bool
    private let mode: Mode
    private let style: Style

    private var window: NSWindow!
    private var webView: WKWebView!
    private var watcher: FileWatcher?

    /// 셸 페이지 로드 완료 여부. 완료 전 들어온 내용은 pendingMarkdown 에 보관한다.
    private var pageLoaded = false
    private var pendingMarkdown: String?

    /// 변경이 잠잠해지면 스트리밍 커서를 끄기 위한 디바운스 작업
    private var settleWork: DispatchWorkItem?

    /// 테마 강제 모드 (⌘T 로 순환). auto 는 시스템 설정을 따른다.
    private enum ThemeMode: String { case auto = "Auto", light = "Light", dark = "Dark" }
    private var themeMode: ThemeMode = .auto

    init(fileURL: URL, watch: Bool, style: Style) {
        self.fileURL = fileURL
        self.watch = watch
        self.style = style
        switch fileURL.pathExtension.lowercased() {
        case "html", "htm": self.mode = .html
        default: self.mode = .markdown
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenu()
        setupWindow()

        switch mode {
        case .html:
            reloadHTMLFile()
        case .markdown:
            // 빈 셸을 먼저 띄우고, 로드 완료(didFinish) 시 본문을 주입한다
            webView.loadHTMLString(HTMLTemplate.shell(style: style), baseURL: fileURL.deletingLastPathComponent())
            pendingMarkdown = readFile()
        }

        if watch {
            watcher = FileWatcher(url: fileURL) { [weak self] in
                MainActor.assumeIsolated { self?.onFileChanged() }
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    // MARK: - WKNavigationDelegate

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard mode == .markdown else { return }
        pageLoaded = true
        if let md = pendingMarkdown {
            pendingMarkdown = nil
            push(md, streaming: watch)
        }
    }

    // MARK: - 파일 변경 처리

    private func onFileChanged() {
        switch mode {
        case .html:
            reloadHTMLFile()
        case .markdown:
            push(readFile(), streaming: watch)
        }
    }

    private func reloadHTMLFile() {
        webView.loadFileURL(fileURL, allowingReadAccessTo: fileURL.deletingLastPathComponent())
    }

    /// 마크다운 본문을 WKWebView 로 주입한다(전체 리로드 없음).
    private func push(_ markdown: String, streaming: Bool) {
        guard pageLoaded else {
            pendingMarkdown = markdown
            return
        }
        guard let json = Self.jsStringLiteral(markdown) else { return }
        webView.evaluateJavaScript("window.__render(\(json), \(streaming));", completionHandler: nil)

        if streaming { scheduleStreamingStop() }
    }

    /// 일정 시간 변경이 없으면 스트리밍 커서를 끈다.
    private func scheduleStreamingStop() {
        settleWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.webView.evaluateJavaScript(
                "document.getElementById('content')?.classList.remove('streaming');",
                completionHandler: nil
            )
        }
        settleWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2, execute: work)
    }

    // MARK: - 유틸

    private func readFile() -> String {
        (try? String(contentsOf: fileURL, encoding: .utf8)) ?? ""
    }

    /// 문자열을 JS 코드에 안전하게 끼워 넣을 수 있는 리터럴("...")로 인코딩한다.
    private static func jsStringLiteral(_ s: String) -> String? {
        guard let data = try? JSONEncoder().encode(s) else { return nil }
        return String(data: data, encoding: .utf8)
    }

    // MARK: - 창 / 메뉴

    private func setupWindow() {
        webView = WKWebView(
            frame: NSRect(x: 0, y: 0, width: 900, height: 720),
            configuration: WKWebViewConfiguration()
        )
        webView.navigationDelegate = self

        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 720),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = fileURL.lastPathComponent + (watch ? "  •  live" : "")
        window.contentView = webView
        window.center()
        window.makeKeyAndOrderFront(nil)
    }

    private func setupMenu() {
        let mainMenu = NSMenu()

        // App 메뉴
        let appItem = NSMenuItem()
        mainMenu.addItem(appItem)
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "Quit mdlive", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appItem.submenu = appMenu

        // File 메뉴 — 내보내기 / 인쇄
        let fileItem = NSMenuItem()
        mainMenu.addItem(fileItem)
        let fileMenu = NSMenu(title: "File")
        add(fileMenu, "Export as PDF…", #selector(exportPDF), "e")
        add(fileMenu, "Export as HTML…", #selector(exportHTML), "e", [.command, .shift])
        fileMenu.addItem(.separator())
        add(fileMenu, "Print…", #selector(printDocument), "p")
        fileMenu.addItem(.separator())
        fileMenu.addItem(withTitle: "Close", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        fileItem.submenu = fileMenu

        // View 메뉴 — 줌 / 테마
        let viewItem = NSMenuItem()
        mainMenu.addItem(viewItem)
        let viewMenu = NSMenu(title: "View")
        add(viewMenu, "Actual Size", #selector(zoomReset), "0")
        add(viewMenu, "Zoom In", #selector(zoomIn), "=")
        add(viewMenu, "Zoom Out", #selector(zoomOut), "-")
        viewMenu.addItem(.separator())
        add(viewMenu, "Toggle Theme", #selector(toggleTheme), "t")
        viewItem.submenu = viewMenu

        // Edit 메뉴 — 복사/전체선택 등 표준 단축키 활성화
        let editItem = NSMenuItem()
        mainMenu.addItem(editItem)
        let editMenu = NSMenu(title: "Edit")
        editMenu.addItem(withTitle: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "Select All", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editItem.submenu = editMenu

        NSApplication.shared.mainMenu = mainMenu
    }

    /// self 를 타깃으로 하는 메뉴 항목을 추가하는 헬퍼.
    private func add(_ menu: NSMenu, _ title: String, _ action: Selector,
                     _ key: String, _ mask: NSEvent.ModifierFlags = [.command]) {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.keyEquivalentModifierMask = mask
        item.target = self
        menu.addItem(item)
    }

    // MARK: - 내보내기 / 인쇄

    @objc private func exportPDF() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = fileURL.deletingPathExtension().lastPathComponent + ".pdf"
        panel.beginSheetModal(for: window) { [weak self] response in
            guard response == .OK, let url = panel.url, let self else { return }
            self.webView.createPDF(configuration: WKPDFConfiguration()) { result in
                if case .success(let data) = result { try? data.write(to: url) }
            }
        }
    }

    @objc private func exportHTML() {
        // 현재 DOM 전체(인라인된 CSS/JS 포함)를 그대로 저장 → 자체완결 HTML
        webView.evaluateJavaScript("'<!DOCTYPE html>\\n' + document.documentElement.outerHTML") { [weak self] result, _ in
            guard let self, let html = result as? String else { return }
            let panel = NSSavePanel()
            panel.allowedContentTypes = [.html]
            panel.nameFieldStringValue = self.fileURL.deletingPathExtension().lastPathComponent + ".html"
            panel.beginSheetModal(for: self.window) { response in
                guard response == .OK, let url = panel.url else { return }
                try? html.data(using: .utf8)?.write(to: url)
            }
        }
    }

    @objc private func printDocument() {
        let op = webView.printOperation(with: NSPrintInfo.shared)
        op.view?.frame = webView.bounds
        op.runModal(for: window, delegate: nil, didRun: nil, contextInfo: nil)
    }

    // MARK: - 줌

    @objc private func zoomIn()    { webView.pageZoom = min(webView.pageZoom * 1.1, 3.0) }
    @objc private func zoomOut()   { webView.pageZoom = max(webView.pageZoom / 1.1, 0.4) }
    @objc private func zoomReset() { webView.pageZoom = 1.0 }

    // MARK: - 테마

    @objc private func toggleTheme() {
        switch themeMode {
        case .auto:
            themeMode = .light
            webView.appearance = NSAppearance(named: .aqua)
        case .light:
            themeMode = .dark
            webView.appearance = NSAppearance(named: .darkAqua)
        case .dark:
            themeMode = .auto
            webView.appearance = nil  // 시스템 설정을 따름
        }
        updateTitle()
    }

    private func updateTitle() {
        var title = fileURL.lastPathComponent
        if watch { title += "  •  live" }
        if themeMode != .auto { title += "  •  \(themeMode.rawValue)" }
        window.title = title
    }
}
