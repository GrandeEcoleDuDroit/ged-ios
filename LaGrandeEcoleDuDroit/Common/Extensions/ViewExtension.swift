import SwiftUI

extension View {
    func clickable(isClicked: Binding<Bool>, onClick: @escaping () -> Void) -> some View {
        self
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
    }
}
