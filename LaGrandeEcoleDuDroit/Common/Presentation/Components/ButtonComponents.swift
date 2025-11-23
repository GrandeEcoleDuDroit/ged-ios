import SwiftUI

struct PrimaryButton: View {
    private let label: String
    private let action: () -> Void
    private let width: CGFloat
    
    init(
        label: String,
        action: @escaping () -> Void,
        width: CGFloat = .infinity
    ) {
        self.label = label
        self.action = action
        self.width = width
    }
    
    var body: some View {
        Button(action: action) {
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
    private let action: () -> Void
    private var isLoading: Bool
    
    init(
        label: String,
        action: @escaping () -> Void,
        isLoading: Bool
    ) {
        self.label = label
        self.action = action
        self.isLoading = isLoading
    }
    
    var body: some View {
        if isLoading {
            Button(action: action) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .foregroundColor(.white)
                    .background(.gedPrimary)
                    .clipShape(.rect(cornerRadius: 30))
            }
        } else {
            PrimaryButton(label: label, action: action, width: .infinity)
        }
    }
}

struct Clickable<Content: View>: View {
    let action: () -> Void
    let backgroundColor: Color
    let content: () -> Content

    init(
        action: @escaping () -> Void,
        backgroundColor: Color = .highlight,
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

struct ClickStyle: ButtonStyle {
    var backgroundColor: Color = .highlight

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? backgroundColor : .clear)
    }
}

struct OptionButton : View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "ellipsis")
        }
    }
}

struct RemoveButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(
            action: action,
            label: {
                Image(systemName: "xmark")
            }
        )
    }
}

struct TextButton: View {
    let text: String
    let onClick: () -> Void
    let enabled: Bool
    
    var body: some View {
        Button(
            action: onClick,
            label: {
                if enabled {
                    Text(text).foregroundStyle(.gedPrimary)
                } else {
                    Text(text)
                }
            }
        )
        .fontWeight(.semibold)
        .disabled(!enabled)
    }
}

#Preview {
    LoadingButton(
        label: "Loading button",
        action: {},
        isLoading : false
    )
    
    HStack {
        Text("Option button")
        OptionButton(action: {})
    }
    
    HStack {
        Text("Remove button")
        RemoveButton(action: {})
    }
}
