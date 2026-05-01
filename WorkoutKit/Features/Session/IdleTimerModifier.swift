import SwiftUI
import UIKit

/// Wraps UIApplication.shared idle-timer management in a ViewModifier.
/// UIApplication.shared is intentionally used here — this is a UIKit-bridging layer,
/// and the guideline of "no .shared in Store/ViewModel" applies to business logic,
/// not to dedicated bridge modifiers like this one.
struct IdleTimerModifier: ViewModifier {
    let disabled: Bool

    func body(content: Content) -> some View {
        content
            .onChange(of: disabled, initial: true) { _, newValue in
                UIApplication.shared.isIdleTimerDisabled = newValue
            }
    }
}

extension View {
    func disableIdleTimer(_ disabled: Bool) -> some View {
        modifier(IdleTimerModifier(disabled: disabled))
    }
}
