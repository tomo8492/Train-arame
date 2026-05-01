import Testing
@testable import WorkoutKit

@Suite("HTMLSanitizer")
struct HTMLSanitizerTests {

    @Test("script タグとその内容を除去する")
    func removesScriptTag() {
        let input = #"<p>Hello</p><script>alert('xss')</script><p>World</p>"#
        let result = HTMLSanitizer.sanitize(input)
        #expect(!result.contains("script"))
        #expect(!result.contains("alert"))
        #expect(result.contains("Hello"))
        #expect(result.contains("World"))
    }

    @Test("iframe タグを除去する")
    func removesIframeTag() {
        let input = #"<p>Text</p><iframe src="evil.com"></iframe>"#
        let result = HTMLSanitizer.sanitize(input)
        #expect(!result.contains("iframe"))
        #expect(result.contains("Text"))
    }

    @Test("許可タグ <p> <strong> <em> <ol> <li> は保持する")
    func preservesAllowedTags() {
        let input = "<p>Hello <strong>World</strong></p><ol><li>Item</li></ol>"
        let result = HTMLSanitizer.sanitize(input)
        #expect(result.contains("<p>"))
        #expect(result.contains("<strong>"))
        #expect(result.contains("<ol>"))
        #expect(result.contains("<li>"))
    }

    @Test("空文字入力は空文字を返す")
    func emptyInputReturnsEmpty() {
        #expect(HTMLSanitizer.sanitize("") == "")
    }

    @Test("on* イベントハンドラ属性を除去する")
    func removesEventHandlerAttributes() {
        let input = #"<p onclick="evil()">Click me</p>"#
        let result = HTMLSanitizer.sanitize(input)
        #expect(!result.contains("onclick"))
        #expect(result.contains("Click me"))
    }

    @Test("javascript: スキームを除去する")
    func removesJavascriptScheme() {
        let input = #"<a href="javascript:alert(1)">link</a>"#
        let result = HTMLSanitizer.sanitize(input)
        #expect(!result.contains("javascript:"))
    }
}
