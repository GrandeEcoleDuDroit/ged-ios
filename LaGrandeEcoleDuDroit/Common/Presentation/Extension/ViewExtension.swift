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
                        .cornerRadius(DimensResource.smallPadding)
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
