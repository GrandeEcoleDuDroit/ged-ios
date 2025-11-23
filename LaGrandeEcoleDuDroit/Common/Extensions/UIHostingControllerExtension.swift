import SwiftUI

extension UIHostingController where Content == AnyView {
    func setView<V: View>(_ view: () -> V) {
        self.rootView = Content(view())
    }
}
