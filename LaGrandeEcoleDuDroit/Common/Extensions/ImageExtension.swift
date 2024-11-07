import SwiftUI

extension Image {
    func fitCircle(scale: CGFloat = 1) -> some View {
        self
            .resizable()
            .scaledToFit()
            .frame(width: GedNumber.defaultImageSize * scale, height: GedNumber.defaultImageSize * scale)
            .clipShape(Circle())
    }
    
    func fitCircleClickable(isClicked: Binding<Bool>, onClick: @escaping () -> Void, scale: CGFloat = 1) -> some View {
        self
            .resizable()
            .overlay(
                Color(UIColor.lightGray)
                    .opacity(isClicked.wrappedValue ? 0.4 : 0)
                    .animation(.easeInOut(duration: 0.2), value: isClicked.wrappedValue)
            )
            .onTapGesture {
                isClicked.wrappedValue = true
                onClick()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isClicked.wrappedValue = false
                }
            }
            .scaledToFit()
            .frame(width: GedNumber.defaultImageSize * scale, height: GedNumber.defaultImageSize * scale)
            .clipShape(Circle())
    }
}
