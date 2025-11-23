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
                Color(.highlight)
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
    
    func outlined(borderColor: Color = .outline) -> some View {
        self
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(borderColor, lineWidth: 2)
            )
            .cornerRadius(5)
    }
}
