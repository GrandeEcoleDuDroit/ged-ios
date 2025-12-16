import SwiftUI

extension View {
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
    
    func listRowTap<Value: Equatable>(
        action: @escaping () -> Void,
        selectedItem: Binding<Value?>,
        value: Value
    ) -> some View {
        self.onTapGesture {
            selectedItem.wrappedValue = value
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                selectedItem.wrappedValue = nil
            }
        }
    }
}
