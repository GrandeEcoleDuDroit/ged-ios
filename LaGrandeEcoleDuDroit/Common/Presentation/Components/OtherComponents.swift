import SwiftUI

struct ItemWithIcon: View {
    private let icon: Image
    private let text: Text
    
    init(icon: Image, text: Text) {
        self.text = text
        self.icon = icon
    }
    
    var body: some View {
        HStack(spacing: GedSpacing.smallMedium) {
            icon
            text
        }
    }
}

#Preview {
    ItemWithIcon(
        icon: Image(systemName: "star"),
        text: Text("Item with icon")
    )
}
