import SwiftUI

extension View {
    func clickEffect(isClicked: Binding<Bool>) -> some View {
        self
            .contentShape(Rectangle())
            .simultaneousGesture(
                TapGesture().onEnded {
                    isClicked.wrappedValue = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isClicked.wrappedValue = false
                    }
                }
            )
            .background(
                Color(.click)
                    .opacity(isClicked.wrappedValue ? 1 : 0)
                    .animation(.easeInOut(duration: 0.1), value: isClicked.wrappedValue)
            )
    }
    
    func loading(_ isLoading: Bool) -> some View {
        self
            .disabled(isLoading)
            .opacity(isLoading ? 0.5 : 1)
            .overlay {
                if isLoading {
                    ProgressView(stringResource(.loading))
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(Dimens.smallPadding)
                        .shadow(radius: 1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .ignoresSafeArea()
                }
            }
    }
}
