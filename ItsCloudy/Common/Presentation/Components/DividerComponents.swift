import SwiftUI

struct HorizontalDivider: View {
    var body: some View {
        Divider()
            .frame(height: 1)
            .overlay(.outlineVariant)
    }
}
