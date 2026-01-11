import SwiftUI

extension Image {
    func resize(
        width: CGFloat = DimensResource.defaultImageSize,
        height: CGFloat = DimensResource.defaultImageSize,
        scale: CGFloat = 1.0
    ) -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(
                width: width * scale,
                height: height * scale
            )
            .clipped()
    }    
}
