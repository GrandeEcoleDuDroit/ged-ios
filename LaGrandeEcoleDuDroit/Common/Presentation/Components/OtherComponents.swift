import SwiftUI

struct ItemWithIcon: View {
    let icon: Image
    let text: Text
    
    var body: some View {
        HStack(spacing: GedSpacing.smallMedium) {
            icon
            text
        }
    }
}

struct ClickableItemWithIcon: View {
    let icon: Image
    let text: Text
    let onClick: () -> Void
    @State private var isClicked = false
    
    var body: some View {
        Button(
            action: onClick,
            label: {
                HStack(spacing: GedSpacing.smallMedium) {
                    icon
                    text
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        )
    }
}

#Preview {
    ItemWithIcon(
        icon: Image(systemName: "star"),
        text: Text("Item with icon")
    )
}
