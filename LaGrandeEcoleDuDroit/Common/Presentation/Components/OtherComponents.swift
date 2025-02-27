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

struct ClickableItemWithIcon: View {
    @State private var isClicked = false
    private let icon: Image
    private let text: Text
    private let onClick: () -> Void
    
    init(
        icon: Image,
        text: Text,
        onClick: @escaping () -> Void
    ) {
        self.text = text
        self.icon = icon
        self.onClick = onClick
    }
    
    var body: some View {
        HStack(spacing: GedSpacing.smallMedium) {
            icon
            text
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .onClick(isClicked: $isClicked, action: onClick)
    }
}

#Preview {
    ItemWithIcon(
        icon: Image(systemName: "star"),
        text: Text("Item with icon")
    )
}
