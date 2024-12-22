import SwiftUI

struct LoadingButton: View {
    let label: String
    let onClick: () -> Void
    @Binding var isLoading: Bool
    
    var body: some View {
        Button(action: onClick) {
            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .foregroundColor(.white)
                    .background(.gedPrimary)
                    .clipShape(.rect(cornerRadius: 30))

            } else {
                Text(label)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .foregroundColor(.white)
                    .background(.gedPrimary)
                    .clipShape(.rect(cornerRadius: 30))
            }
        }
        .disabled(isLoading)
    }
}

#Preview {
    VStack(spacing: GedSpacing.verylLarge) {
        LoadingButton(
            label: "Loading button",
            onClick: {},
            isLoading : .constant(false)
        )        
    }.padding()
}
