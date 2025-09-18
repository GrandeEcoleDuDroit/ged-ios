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

struct Clickable<Content: View>: View {
    let action: () -> Void
    let backgroundColor: Color
    let content: () -> Content

    init(
        action: @escaping () -> Void,
        backgroundColor: Color = .click,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.action = action
        self.backgroundColor = backgroundColor
        self.content = content
    }

    var body: some View {
        Button(
            action: action,
            label: content
        )
        .buttonStyle(ClickStyle(backgroundColor: backgroundColor))
    }
}

private struct ClickStyle: ButtonStyle {
    var backgroundColor: Color = .click

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                backgroundColor
                    .opacity(configuration.isPressed ? 1 : 0)
                    .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
            )
    }
}

#Preview {
    VStack {
        LoadingButton(
            label: "Loading button",
            onClick: {},
            isLoading : false
        )
    }.padding()
}
