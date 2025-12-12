import SwiftUI

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
        HStack(spacing: .zero) {
            leadingContent
                .padding(.trailing, Dimens.mediumPadding)
            
            HStack(spacing: Dimens.mediumPadding) {
                VStack(alignment: .leading, spacing: Dimens.extraSmallPadding) {
                    headlineContent
                    supportingContent
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                trailingContent
            }
        }
        .padding(.vertical, Dimens.smallPadding)
        .padding(.horizontal)
    }
}

#Preview {
    PlainListItem(
        headlineContent: { Text("Plain list item") },
        leadingContent: { Image(systemName: "star") },
        trailingContent: { Image(systemName: "chevron.right") }
    )
}
