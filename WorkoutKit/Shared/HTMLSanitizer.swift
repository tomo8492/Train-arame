import Foundation

/// 危険なHTMLタグを除去し、許可タグのみを残す軽量サニタイザー。
/// 副作用なし・外部依存なし。
enum HTMLSanitizer {
    /// 許可するタグ一覧
    static let allowedTags: Set<String> = [
        "p", "ol", "ul", "li", "strong", "em", "br", "h1", "h2", "h3", "span"
    ]

    /// 危険タグを除去したHTMLを返す。
    /// - Parameter html: 入力HTML文字列
    /// - Returns: サニタイズ済みHTML文字列
    static func sanitize(_ html: String) -> String {
        guard !html.isEmpty else { return "" }

        var result = html

        // 1. 危険タグをコンテンツごと除去 (script, style, iframe, object, embed, form, svg, math)
        let dangerousTagsWithContent = ["script", "style", "iframe", "object", "embed", "form", "svg", "math"]
        for tag in dangerousTagsWithContent {
            // タグ全体（開始〜終了タグのコンテンツを含む）を除去
            let pattern = "<\(tag)[^>]*>[\\s\\S]*?</\(tag)>"
            result = removeMatches(pattern: pattern, from: result, options: [.caseInsensitive, .dotMatchesLineSeparators])

            // 自己閉じタグも除去
            let selfClosingPattern = "<\(tag)[^>]*/>"
            result = removeMatches(pattern: selfClosingPattern, from: result, options: [.caseInsensitive])

            // 開始タグのみ（内容なし）も除去
            let openTagPattern = "<\(tag)[^>]*>"
            result = removeMatches(pattern: openTagPattern, from: result, options: [.caseInsensitive])
        }

        // 2. on* イベントハンドラ属性を除去 (onclick=, onload= etc.)
        let eventHandlerPattern = #"\s+on\w+\s*=\s*(?:"[^"]*"|'[^']*'|[^\s>]*)"#
        result = removeMatches(pattern: eventHandlerPattern, from: result, options: [.caseInsensitive])

        // 3. javascript: スキームを除去 (href="javascript:...", src="javascript:...")
        let jsSchemePattern = #"javascript\s*:"#
        result = removeMatches(pattern: jsSchemePattern, from: result, options: [.caseInsensitive])

        return result
    }

    // MARK: - Private helpers

    private static func removeMatches(
        pattern: String,
        from input: String,
        options: NSRegularExpression.Options = []
    ) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else {
            return input
        }
        let range = NSRange(input.startIndex..., in: input)
        return regex.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: "")
    }
}
