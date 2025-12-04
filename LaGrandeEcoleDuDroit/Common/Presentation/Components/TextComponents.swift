import SwiftUI

struct TextIcon: View {
    let icon: Image
    let text: String
    
    var body: some View {
        HStack(alignment: .center, spacing: Dimens.mediumPadding) {
            icon
                .resizable()
                .scaledToFill()
                .frame(width: Dimens.iconSize, height: Dimens.iconSize)
            
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
