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
                .padding(.horizontal)
            }
        )
    }
}

struct BottomSheetContainer<Content: View>: View {
    let fraction: CGFloat
    let content: Content
    
    init(fraction: CGFloat, @ViewBuilder content: () -> Content) {
        self.fraction = fraction
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 28) {
            content
        }
        .presentationDetents([.fraction(fraction)])
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .padding(.bottom)
    }
}

#Preview {
    ItemWithIcon(
        icon: Image(systemName: "star"),
        text: Text("Item with icon")
    ).background(.red)
    
    ClickableItemWithIcon(
        icon: Image(systemName: "star"),
        text: Text("Item with icon"),
        onClick: {}
    ).background(.blue)
}
