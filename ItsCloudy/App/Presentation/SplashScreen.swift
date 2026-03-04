import SwiftUI

struct SplashScreen: View {
    private let imageSize: CGFloat = DimensResource.defaultImageSize * 2
    
    var body: some View {
        Image(.appLogo)
            .resizable()
            .scaledToFit()
            .frame(width: imageSize, height: imageSize)
            .clipped()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(.appBackground)
    }
}

#Preview {
    SplashScreen()
        .background(.appBackground)
        .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
