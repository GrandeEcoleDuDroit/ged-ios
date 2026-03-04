import SwiftUI

struct NavigationListItem<Content: View>: View {
    let onClick: () -> Void
    @ViewBuilder let content: () -> Content

    init(
        onClick: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.onClick = onClick
        self.content = content
    }

    var body: some View {
        Button(action: onClick) {
            HStack(spacing: DimensResource.mediumPadding) {
                content()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                Image(systemName: "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .foregroundStyle(.gray)
            }
        }
    }
}

extension NavigationListItem {
    init(
        image: Image? = nil,
        text: String,
        onClick: @escaping () -> Void
    ) where Content == NavigationListItemRow {
        self.init(onClick: onClick) {
            NavigationListItemRow(
                image: image,
                text: text
            )
        }
    }
}


struct NavigationListItemRow: View {
    let image: Image?
    let text: String

    var body: some View {
        HStack(spacing: DimensResource.mediumPadding) {
            if let image {
                image
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: DimensResource.iconSize,
                        height: DimensResource.iconSize
                    )
            }

            Text(text)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct PlainListItem<
    LeadingContent: View,
    HeadlineContent: View,
    SupportingContent: View,
    TrailingContent: View
>: View {
    let leadingContent: LeadingContent
    let headlineContent: HeadlineContent
    let trailingContent: TrailingContent
    let supportingContent: SupportingContent
    
    init(
        headlineContent: () -> HeadlineContent,
        leadingContent: () -> LeadingContent = { EmptyView() },
        trailingContent: () -> TrailingContent = { EmptyView() },
        supportingContent: () -> SupportingContent = { EmptyView() }
    ) {
        self.headlineContent = headlineContent()
        self.leadingContent = leadingContent()
        self.trailingContent = trailingContent()
        self.supportingContent = supportingContent()
    }
    
    var body: some View {
        HStack(spacing: DimensResource.smallPadding) {
            leadingContent
                .padding(.trailing, DimensResource.smallPadding)
            
            HStack(spacing: DimensResource.mediumPadding) {
                VStack(alignment: .leading, spacing: DimensResource.extraSmallPadding) {
                    headlineContent
                    supportingContent
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                trailingContent
            }
        }
        .padding(.horizontal)
        .padding(.vertical, DimensResource.smallPadding + 2)
    }
}

#Preview {
    NavigationListItem(
        text: "Navigation list item",
        onClick: {}
    )
    
    PlainListItem(
        headlineContent: { Text("Plain list item") },
        leadingContent: { Image(systemName: "star") }
    )
}
