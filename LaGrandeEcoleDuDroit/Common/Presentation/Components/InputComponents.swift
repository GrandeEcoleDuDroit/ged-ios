import SwiftUI

struct OutlineTextField<Leading: View>: View {
    private let initialText: String
    private let onTextChange: (String) -> String
    private let placeHolder: String
    private let axis: Axis
    private let disabled: Bool
    private let errorMessage: String?
    private let leading: Leading
    
    @FocusState private var focusState: Field?
    private var field: Field?
    @State private var currentText: String = ""
    
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
        initialText: String,
        onTextChange: @escaping (String) -> String,
        placeHolder: String,
        axis: Axis = .horizontal,
        disabled: Bool = false,
        errorMessage: String? = nil,
        @ViewBuilder leading: () -> Leading = { EmptyView() }
    ) {
        self.initialText = initialText
        self.onTextChange = onTextChange
        self.placeHolder = placeHolder
        self.axis = axis
        self.disabled = disabled
        self.errorMessage = errorMessage
        self.leading = leading()
        
        currentText = initialText
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: Dimens.leadingIconSpacing) {
                leading.foregroundStyle(placeHolderColor)
                
                TextField(
                    "",
                    text: $currentText,
                    prompt: Text(placeHolder).foregroundColor(placeHolderColor),
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
        .onChange(of: currentText) {
            currentText = onTextChange($0)
        }
    }
}

extension OutlineTextField {
    func setTextFieldFocusState(focusState: FocusState<Field?>, field: Field) -> Self {
        var copy = self
        copy._focusState = focusState
        copy.field = field
        return copy
    }
}

struct TransparentTextField: View {
    let text: String
    let onTextChange: (String) -> String
    let placeHolder: String
    
    init(
        initialText: String,
        onTextChange: @escaping (String) -> String,
        placeHolder: String
    ) {
        self.text = initialText
        self.onTextChange = onTextChange
        self.placeHolder = placeHolder
        
        currentText = initialText
    }
    
    @FocusState private var focusState: Field?
    private var field: Field?
    @State private var currentText: String

    var body: some View {
        TextField(
            "",
            text: $currentText,
            prompt: Text(placeHolder).foregroundColor(.onSurfaceVariant),
            axis: .vertical
        )
        .focused($focusState, equals: field)
        .onChange(of: currentText) {
            currentText = onTextChange($0)
        }
    }
}

extension TransparentTextField {
    func setTextFieldFocusState(focusState: FocusState<Field?>, field: Field) -> Self {
        var copy = self
        copy._focusState = focusState
        copy.field = field
        return copy
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
        initialText: "",
        onTextChange: { _ in "" },
        placeHolder: "Email",
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
