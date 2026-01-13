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
