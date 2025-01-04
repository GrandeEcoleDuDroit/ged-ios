import SwiftUI

struct LoadingButton: View {
    private let label: String
    private let onClick: () -> Void
    private var isLoading: Bool
    
    init(
        label: String,
        onClick: @escaping () -> Void,
        isLoading: Bool
    ) {
        self.label = label
        self.onClick = onClick
        self.isLoading = isLoading
    }
    
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
    VStack(spacing: GedSpacing.veryLarge) {
        LoadingButton(
            label: "Loading button",
            onClick: {},
            isLoading : false
        )        
    }.padding()
}
