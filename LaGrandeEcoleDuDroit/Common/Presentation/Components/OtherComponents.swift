import SwiftUI

struct TextItem: View {
    let icon: Image?
    let text: Text
    
    init(icon: Image? = nil, text: Text) {
        self.icon = icon
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .center) {
            icon?.frame(width: 24)
            text
        }
    }
}

struct ClickableTextItem: View {
    let icon: Image?
    let text: Text
    let onClick: () -> Void
    
    init(
        icon: Image? = nil,
        text: Text,
        onClick: @escaping () -> Void
    ) {
        self.icon = icon
        self.text = text
        self.onClick = onClick
    }
    
    var body: some View {
        Button(
            action: onClick,
            label: {
                HStack(alignment: .center) {
                    icon.frame(width: 24)
                    text
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        )
    }
}

struct MenuItem: View {
    let icon: Image?
    let title: String
    let onClick: () -> Void
    
    init(
        icon: Image? = nil,
        title: String,
        onClick: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.onClick = onClick
    }
    
    var body: some View {
        Button(
            action: onClick,
            label: {
                HStack(alignment: .center) {
                    icon?.frame(width: 24)
                    Text(title)
                    Spacer()
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        )
    }
}

struct BottomSheetContainer<Content: View>: View {
    let fraction: CGFloat
    let content: Content
    
    init(
        fraction: CGFloat,
        @ViewBuilder content: () -> Content
    ) {
        self.fraction = fraction
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 30) {
            content
        }
        .presentationDetents([.fraction(fraction)])
        .padding(.horizontal)
    }
}

struct CheckBox: View {
    let checked: Bool
    let onCheckedChange: (Bool) -> Void

    var body: some View {
        Image(systemName: checked ? "checkmark.square.fill" : "square")
            .foregroundColor(checked ? .gedPrimary : Color.secondary)
            .onTapGesture {
                onCheckedChange(!checked)
            }
    }
}

#Preview {
    VStack(
        alignment: .leading,
        spacing: Dimens.mediumPadding
    ) {
        TextItem(
            icon: Image(systemName: "key"),
            text: Text("Item with icon")
        )
        
        ClickableTextItem(
            icon: Image(systemName: "rectangle.portrait.and.arrow.right"),
            text: Text("Clickable item with icon"),
            onClick: {}
        )
        
        MenuItem(
            icon: Image(systemName: "star"),
            title: "Menu item",
            onClick: {}
        )
        
        CheckBox(
            checked: true,
            onCheckedChange: { _ in }
        )
    }
    .padding(.horizontal)
    .sheet(isPresented: .constant(true)) {
        BottomSheetContainer(fraction: 0.16) {
            Text("Bottom sheet content")
        }
    }
}
