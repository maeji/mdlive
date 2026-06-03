import Foundation

/// 파일의 수정 시각(mtime)을 주기적으로 폴링해 변경을 감지한다.
///
/// 에디터의 원자적 저장(임시 파일 생성 후 rename)으로 파일 디스크립터가
/// 무효화되는 경우가 많아, vnode 이벤트보다 mtime 폴링이 더 견고하다.
final class FileWatcher {

    private let url: URL
    private let onChange: @Sendable () -> Void
    private let timer: DispatchSourceTimer
    private var lastModified: Date?

    init(url: URL, interval: TimeInterval = 0.4, onChange: @escaping @Sendable () -> Void) {
        self.url = url
        self.onChange = onChange
        self.lastModified = Self.modificationDate(of: url)

        timer = DispatchSource.makeTimerSource(queue: .global(qos: .utility))
        timer.schedule(deadline: .now() + interval, repeating: interval)
        timer.setEventHandler { [weak self] in
            self?.poll()
        }
        timer.resume()
    }

    deinit {
        timer.cancel()
    }

    private func poll() {
        guard let current = Self.modificationDate(of: url) else { return }
        if current != lastModified {
            lastModified = current
            let callback = onChange
            DispatchQueue.main.async {
                callback()
            }
        }
    }

    private static func modificationDate(of url: URL) -> Date? {
        let attrs = try? FileManager.default.attributesOfItem(atPath: url.path)
        return attrs?[.modificationDate] as? Date
    }
}
