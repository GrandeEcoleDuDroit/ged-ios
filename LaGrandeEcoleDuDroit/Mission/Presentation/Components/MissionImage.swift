import SwiftUI

struct MissionImage: View {
    let model: String?
    var defaultImageScale: CGFloat = 1.2
    
    var body: some View {
        if let model {
            SimpleAsyncImage(url: model)
        } else {
            DefaultImage(scale: defaultImageScale)
        }
    }
}

private struct DefaultImage: View {
    let scale: CGFloat
    
    var body: some View {
        Image(systemName: "target")
            .fit(scale: scale)
            .foregroundStyle(.defaultImageForeground)
            .padding(Dimens.mediumPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.surfaceVariant)
    }
}
    
#Preview {
    MissionImage(model: nil)
}
