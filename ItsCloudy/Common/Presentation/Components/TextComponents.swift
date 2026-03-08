import SwiftUI

struct TextIcon: View {
    let icon: Image
    let text: String
    var spacing: CGFloat? = DimensResource.mediumPadding
    
    var body: some View {
        HStack(alignment: .center, spacing: spacing) {
            icon
                .resizable()
                .scaledToFit()
                .frame(width: DimensResource.iconSize, height: DimensResource.iconSize)
            
            Text(text)
        }
    }
}

struct EmptyText: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .foregroundStyle(.informationText)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct ExpandableText: View {
    let text: String
    var maxLines: Int = 5
    
    @State private var expanded: Bool = false
    @State private var displayShowMoreText: Bool = false
    @State private var height = CGFloat.zero

    var body: some View {
        VStack(alignment: .leading, spacing: DimensResource.extraSmallPadding) {
            if expanded {
                Text(text)
            } else if height < CGFloat(maxLines) * 21 {
                Text(text)
                    .lineLimit(maxLines)
            } else {
                Text(text)
                    .lineLimit(maxLines)
                
                Button(
                    stringResource(.seeMore),
                    action: { expanded = true }
                )
                .buttonStyle(.plain)
                .foregroundStyle(.appPrimary)
                .fontWeight(.semibold)
                .font(.callout)
            }
        }
        .background(
            GeometryReader { geo in
                Color.clear.onAppear { height = geo.size.height }
            }
        )
    }
}

#Preview("Text icon") {
    TextIcon(
        icon: Image(systemName: "xmark"),
        text: "text icon"
    )
}

#Preview("Empty text") {
    EmptyText("Empty text")
}

#Preview("Expandable text") {
    ExpandableText(
        text: CommonPresentationUtils.loremIpsum(),
        maxLines: 2
    )
}
