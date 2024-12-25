import SwiftUI

extension View {
    func onClick(isClicked: Binding<Bool>, action: @escaping () -> Void) -> some View {
        self
            .background(
                Color(.lightGrey)
                    .opacity(isClicked.wrappedValue ? 0.4 : 0)
                    .animation(.easeInOut(duration: 0.1), value: isClicked.wrappedValue)
            )
            .onTapGesture {
                isClicked.wrappedValue = true
                action()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isClicked.wrappedValue = false
                }
            }
    }
    
    func onLongClick(isClicked: Binding<Bool>, action: @escaping () -> Void) -> some View {
        self
            .background(
                Color(.lightGrey)
                    .opacity(isClicked.wrappedValue ? 0.4 : 0)
                    .animation(.easeInOut(duration: 0.1), value: isClicked.wrappedValue)
            )
            .onLongPressGesture(minimumDuration: 0.1, pressing: { isClicked.wrappedValue = $0 }) {
                isClicked.wrappedValue = true
                action()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    isClicked.wrappedValue = false
                }
            }
    }
}
