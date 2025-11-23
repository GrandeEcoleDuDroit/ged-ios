import SwiftUI

struct OutlineTextField<Leading: View>: View {
    let label: String
    let text: String
    let onTextChange: (String) -> Void
    let disabled: Bool
    let errorMessage: String?
    @FocusState var focusState: Field?
    let field: Field?
    let leading: Leading
    
    private var borderColor: Color {
        if errorMessage != nil {
            .error
        } else if disabled {
            .disableBorder
        } else {
            .outline
        }
    }
    
    private var borderWeight: CGFloat {
        if focusState == field {
            4
        } else {
            2
        }
    }
    
    private var placeHolderColor: Color {
        if disabled {
            .disableText
        } else {
            .onSurfaceVariant
        }
    }
    
    private var textColor: Color {
        if disabled {
            .disableText
        } else {
            .primary
        }
    }
    
    init(
        label: String,
        text: String,
        onTextChange: @escaping (String) -> Void,
        disabled: Bool = false,
        errorMessage: String? = nil,
        focusState: FocusState<Field?>? = nil,
        field: Field? = nil,
        @ViewBuilder leading: () -> Leading = { EmptyView() }
    ) {
        self.label = label
        self.text = text
        self.onTextChange = onTextChange
        self.disabled = disabled
        self.errorMessage = errorMessage
        self._focusState = focusState ?? FocusState()
        self.field = field
        self.leading = leading()
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: Dimens.leadingIconSpacing) {
                leading.foregroundStyle(placeHolderColor)
                
                TextField(
                    "",
                    text: Binding(
                        get: { text },
                        set: onTextChange
                    ),
                    prompt: Text(label).foregroundColor(placeHolderColor),
                )
                .foregroundStyle(textColor)
                .focused($focusState, equals: field)
            }
            .outlined(borderColor: borderColor)
            .disabled(disabled)
            
            if errorMessage != nil {
                Text(errorMessage!)
                    .padding(.leading, Dimens.mediumPadding)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

struct OutlinePasswordTextField: View {
    let label: String
    let text: String
    let onTextChange: (String) -> Void
    let isDisabled: Bool
    let errorMessage: String?
    @FocusState var focusState: Field?
    let field: Field
    
    @State private var showPassword = false

    private var borderColor: Color {
        if errorMessage != nil {
            .error
        } else if isDisabled {
            .disableBorder
        } else {
            .outline
        }
    }
    
    private var borderWeight: CGFloat {
        if focusState == field {
            2
        } else {
            1
        }
    }
    
    private var verticalPadding: CGFloat {
        showPassword ? 15.5 : 16
    }
    
    private var placeHolderColor: Color {
        if isDisabled {
            .disableText
        } else {
            .onSurfaceVariant
        }
    }
    
    private var textColor: Color {
        if isDisabled {
            .disableText
        } else {
            .primary
        }
    }
    
    init(
        label: String,
        text: String,
        onTextChange: @escaping (String) -> Void,
        isDisable: Bool = false,
        errorMessage: String? = nil,
        focusState: FocusState<Field?>,
        field: Field
    ) {
        self.label = label
        self.text = text
        self.onTextChange = onTextChange
        self.isDisabled = isDisable
        self.errorMessage = errorMessage
        self._focusState = focusState
        self.field = field
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if(!showPassword) {
                    SecureField(
                        "",
                        text: Binding(
                            get: { text },
                            set: onTextChange
                        ),
                        prompt: Text(label).foregroundColor(placeHolderColor)
                    )
                    .foregroundColor(textColor)
                    .textInputAutocapitalization(.never)
                    .textContentType(.password)
                    .focused($focusState, equals: field)
                    
                    Image(systemName: "eye.slash")
                        .foregroundColor(placeHolderColor)
                        .onTapGesture {
                            showPassword = true
                        }
                } else {
                    TextField(
                        "",
                        text: Binding(
                            get: { text },
                            set: onTextChange
                        ),
                        prompt: Text(label).foregroundColor(placeHolderColor)
                    )
                    .foregroundColor(textColor)
                    .textInputAutocapitalization(.never)
                    .textContentType(.password)
                    .focused($focusState, equals: field)
                
                    Image(systemName: "eye")
                        .foregroundColor(placeHolderColor)
                        .onTapGesture {
                            showPassword = false
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, verticalPadding)
            .cornerRadius(5)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(borderColor, lineWidth: 1)
            )
            .disabled(isDisabled)
            
            if errorMessage != nil {
                Text(errorMessage!)
                    .padding(.leading, Dimens.mediumPadding)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    OutlineTextField(
        label: "Email",
        text: "",
        onTextChange: { _ in },
        disabled: false,
        errorMessage: nil
    )
    
    OutlinePasswordTextField(
        label: "Password",
        text: "",
        onTextChange: { _ in },
        isDisable: false,
        errorMessage: nil,
        focusState: FocusState<Field?>(),
        field: .password
    )
}
