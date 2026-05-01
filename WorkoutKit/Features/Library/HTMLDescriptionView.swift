import SwiftUI
import os.log

private let logger = Logger(subsystem: "com.tomo.workoutkit", category: "HTMLDescriptionView")

/// Exercise の説明HTMLをAttributedStringでレンダリングするビュー。
/// HTMLSanitizer でサニタイズしてから描画する。
struct HTMLDescriptionView: View {
    let html: String

    var body: some View {
        ScrollView {
            Text(makeAttributedString())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
    }

    private func makeAttributedString() -> AttributedString {
        // NSAttributedString HTML conversion is main-thread only; dispatch safely.
        // Since SwiftUI body evaluation is on the main thread, this is safe here.
        let sanitized = HTMLSanitizer.sanitize(html)
        return Self.convert(html: sanitized)
    }

    @MainActor
    private static func convert(html: String) -> AttributedString {
        guard let data = html.data(using: .utf8) else {
            logger.debug("HTMLDescriptionView: failed to encode html as utf8")
            return AttributedString(html)
        }

        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]

        do {
            let nsAttr = try NSAttributedString(data: data, options: options, documentAttributes: nil)
            return try AttributedString(nsAttr, including: \.uiKit)
        } catch {
            logger.debug("HTMLDescriptionView: NSAttributedString conversion failed — \(error.localizedDescription)")
            return AttributedString(html)
        }
    }
}

// MARK: - Preview

#Preview {
    HTMLDescriptionView(
        html: "<p>Hello <strong>World</strong></p><ol><li>Step 1</li><li>Step 2</li></ol>"
    )
}
