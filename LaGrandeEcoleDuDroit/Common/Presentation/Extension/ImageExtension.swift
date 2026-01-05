import SwiftUI

extension Image {
    func resize(
        width: CGFloat = Dimens.defaultImageSize,
        height: CGFloat = Dimens.defaultImageSize,
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
