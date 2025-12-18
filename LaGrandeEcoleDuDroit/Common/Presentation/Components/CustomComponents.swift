import SwiftUI

struct TextItem: View {
    let text: Text
    let image: Image
    
    var body: some View {
        HStack(spacing: Dimens.mediumPadding) {
            image
            text
        }
    }
}

struct ClickableTextItem: View {
    let image: Image?
    let text: Text
    let onClick: () -> Void
    
    init(
        icon: Image? = nil,
        text: Text,
        onClick: @escaping () -> Void
    ) {
        self.image = icon
        self.text = text
        self.onClick = onClick
    }
    
    var body: some View {
        Button(
            action: onClick,
            label: {
                HStack(spacing: Dimens.mediumPadding) {
                    image
                    text
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        )
    }
}

struct PlainListItem<
    LeadingContent: View,
    TrailingContent: View,
    HeadlineContent: View
>: View {
    let leadingContent: LeadingContent
    let headlineContent: HeadlineContent
    let trailingContent: TrailingContent
    
    init(
        headlineContent: () -> HeadlineContent = { EmptyView() },
        leadingContent: () -> LeadingContent = { EmptyView() },
        trailingContent: () -> TrailingContent = { EmptyView() }
    ) {
        self.headlineContent = headlineContent()
        self.leadingContent = leadingContent()
        self.trailingContent = trailingContent()
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: .zero) {
            leadingContent
                .padding(.trailing, Dimens.mediumPadding)
            
            headlineContent
                .frame(maxWidth: .infinity, alignment: .leading)
            
            trailingContent
        }
        .padding(.vertical, Dimens.smallPadding)
        .padding(.horizontal)
    }
}

struct ListItem: View {
    let image: Image?
    let text: Text
    
    init(
        image: Image? = nil,
        text: Text
    ) {
        self.image = image
        self.text = text
    }
    
    var body: some View {
        HStack(spacing: Dimens.mediumPadding) {
            image
            text.frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.right")
                .foregroundStyle(.gray)
        }
    }
}

struct SheetContainer<Content: View>: View {
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

    var body: some View {
        Image(systemName: checked ? "checkmark.square.fill" : "square")
            .foregroundColor(checked ? .gedPrimary : Color.secondary)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 20) {
        TextItem(
            text: Text("Item with icon"),
            image: Image(systemName: "key")
        )
        
        ClickableTextItem(
            icon: Image(systemName: "rectangle.portrait.and.arrow.right"),
            text: Text("Clickable text item"),
            onClick: {}
        )
        
        PlainListItem(
            headlineContent: { Text("Plain list item") },
            leadingContent: { Image(systemName: "star") },
            trailingContent: { Image(systemName: "chevron.right") }
        )
        
        HStack {
            Text("Checkbox")
            CheckBox(
                checked: true
            )
        }
    }
    .frame(maxWidth: .infinity)
}
