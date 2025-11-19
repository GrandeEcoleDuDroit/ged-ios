import SwiftUI

extension Image {
    func fit(scale: CGFloat = 1) -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(
                width: Dimens.defaultImageSize * scale,
                height: Dimens.defaultImageSize * scale
            )
            .clipped()
    }
}
