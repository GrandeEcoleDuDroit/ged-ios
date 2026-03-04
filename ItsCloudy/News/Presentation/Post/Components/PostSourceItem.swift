import SwiftUI

struct PostSourceItem: View {
    let postSource: Post.PostSource
    let date: Date
    let contentSize: SizeTokens
    let elapsedTimeValueFormat: ElapsedTimeValueFormat
    
    init(
        postSource: Post.PostSource,
        date: Date,
        contentSize: SizeTokens = .small,
        elapsedTimeValueFormat: ElapsedTimeValueFormat = .short
    ) {
        self.postSource = postSource
        self.date = date
        self.contentSize = contentSize
        self.elapsedTimeValueFormat = elapsedTimeValueFormat
    }
    
    var body: some View {
        HStack {
            PostSourceIcon(postSource: postSource)
            
            Text(postSource.label)
            
            Text("\u{2022}")
            
            Text(getElapsedTimeValue(date: date, format: elapsedTimeValueFormat))
        }
        .foregroundStyle(.informationText)
        .font(.footnote)
    }
}

private struct PostSourceIcon: View {
    let postSource: Post.PostSource
    
    var body: some View {
        Group {
            switch postSource {
                case .linkedin: Image(.icLinkedin).resizable()
                case .instagram: Image(.icInstagram).resizable()
                case .blogLlm: Image(.appLogo).resizable()
                case .unknown: Image(systemName: "questionmark.circle")
            }
        }.frame(width: DimensResource.smallIconSIze, height: DimensResource.smallIconSIze)
    }
}

#Preview {
    PostSourceItem(
        postSource: .blogLlm,
        date: .now
    )
}
