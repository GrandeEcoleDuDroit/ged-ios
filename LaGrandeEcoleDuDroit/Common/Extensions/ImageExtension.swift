import SwiftUI

extension Image {
    func fitCircle(scale: CGFloat = 1) -> some View {
        self
            .resizable()
            .scaledToFill()
            .frame(width: GedNumber.defaultImageSize * scale, height: GedNumber.defaultImageSize * scale)
            .clipShape(Circle())
    }
}
