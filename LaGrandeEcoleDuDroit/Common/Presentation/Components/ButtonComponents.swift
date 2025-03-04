import SwiftUI

struct PrimaryButton: View {
    private let label: String
    private let onClick: () -> Void
    private let width: CGFloat
    
    init(
        label: String,
        onClick: @escaping () -> Void,
        width: CGFloat = .infinity
    ) {
        self.label = label
        self.onClick = onClick
        self.width = width
    }
    
    var body: some View {
        Button(action: onClick) {
            Text(label)
                .frame(maxWidth: width)
                .padding(10)
                .foregroundColor(.white)
                .background(.gedPrimary)
                .clipShape(.rect(cornerRadius: 30))
        }
    }
}

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
        if isLoading {
            Button(action: onClick) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .foregroundColor(.white)
                    .background(.gedPrimary)
                    .clipShape(.rect(cornerRadius: 30))
            }
        } else {
            PrimaryButton(label: label, onClick: onClick, width: .infinity)
        }
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
