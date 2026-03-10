import SwiftUI

struct PrimaryButton: View {
    private let label: String
    private let action: () -> Void
    private let maxWidth: CGFloat
    private let enabled: Bool
    private let containerColor: Color
    private let contentColor: Color
    
    init(
        label: String,
        action: @escaping () -> Void,
        maxWidth: CGFloat = .infinity,
        enabled: Bool = true,
        containerColor: Color = .appPrimary,
        contentColor: Color = .white
    ) {
        self.label = label
        self.action = action
        self.maxWidth = maxWidth
        self.enabled = enabled
        self.containerColor = containerColor
        self.contentColor = contentColor
    }
    
    var body: some View {
        Button(action: action) {
            if enabled {
                Text(label)
                    .fontWeight(.semibold)
                    .font(.callout)
                    .frame(maxWidth: maxWidth)
                    .padding(10)
                    .foregroundStyle(contentColor)
                    .background(containerColor)
                    .clipShape(ShapeDefaults.full)
            } else {
                Text(label)
                    .frame(maxWidth: maxWidth)
                    .padding(10)
                    .foregroundStyle(.disabledButtonContent)
                    .background(.disabledButtonContainer)
                    .clipShape(ShapeDefaults.full)
            }
        }
        .disabled(!enabled)
    }
}

struct LoadingButton: View {
    private let label: String
    private let loading: Bool
    private let action: () -> Void
    private let enabled: Bool
    private let containerColor: Color
    private let contentColor: Color
    
    init(
        label: String,
        loading: Bool,
        action: @escaping () -> Void,
        enabled: Bool = true,
        containerColor: Color = .appPrimary,
        contentColor: Color = .white
    ) {
        self.label = label
        self.loading = loading
        self.action = action
        self.enabled = enabled
        self.containerColor = containerColor
        self.contentColor = contentColor
    }
    
    var body: some View {
        if loading {
            Button(action: action) {
                if enabled {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: contentColor))
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .foregroundStyle(contentColor)
                        .background(containerColor)
                        .clipShape(.rect(cornerRadius: 30))
                        .frame(maxWidth: .infinity)
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color.disabledButtonContent))
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .foregroundStyle(.disabledButtonContent)
                        .background(.disabledButtonContainer)
                        .clipShape(.rect(cornerRadius: 30))
                        .frame(maxWidth: .infinity)
                }
            }
            .disabled(!enabled)
        } else {
            PrimaryButton(
                label: label,
                action: action,
                enabled: enabled,
                containerColor: containerColor,
                contentColor: contentColor
            )
        }
    }
}

struct ClickStyle: ButtonStyle {
    var backgroundColor: Color = .click

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? backgroundColor : .clear)
    }
}

struct OptionsButton : View {
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
        Button(action: action) {
            Image(systemName: "xmark")
        }
        .foregroundStyle(.onSurfaceVariant)
    }
}

struct TextButton: View {
    let text: String
    let onClick: () -> Void
    let enabled: Bool
    
    var body: some View {
        Button(action: onClick) {
            if enabled {
                Text(text).foregroundStyle(.appPrimary)
            } else {
                Text(text)
            }
        }
        .fontWeight(.semibold)
        .disabled(!enabled)
    }
}

struct OutlinedButton: View {
    let text: String
    let modifier: Modifier
    let action: () -> Void
    
    private let maxWidth: CGFloat? = nil
    
    init(
        _ text: String,
        modifier: Modifier = Modifier(),
        action: @escaping () -> Void
    ) {
        self.text = text
        self.modifier = modifier
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .fontWeight(.semibold)
                .font(.callout)
                .frame(maxWidth: modifier.maxWidth)
                .padding(DimensResource.smallPadding)
                .padding(.horizontal, 10)
                .foregroundStyle(.appPrimary)
                .overlay(
                    ShapeDefaults.full
                        .stroke(.outline, lineWidth: 1)
                )
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 20) {
        PrimaryButton(
            label: "Primary button",
            action: {}
        )
        
        LoadingButton(
            label: "Loading button",
            loading : false,
            action: {}
        )
        
        OptionsButton(action: {})
        
        RemoveButton(action: {})
        
        Button(action: {}) {
            Text("Click style")
                .padding(10)
        }
        .buttonStyle(ClickStyle())
        
        OutlinedButton(
            "Outlined button",
            action: {}
        )
    }
    .padding(.horizontal)
}
