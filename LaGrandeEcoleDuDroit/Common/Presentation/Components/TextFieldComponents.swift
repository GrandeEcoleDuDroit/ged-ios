import SwiftUI

struct OutlinedTextField: View {
    private let initialText: String
    private let onTextChange: (String) -> String
    private let placeHolder: String
    private let axis: Axis
    private let disabled: Bool
    private let errorMessage: String?
    private let leadingIcon: Image?
    
    @FocusState private var focusState: Field?
    private var field: Field?
    @State private var currentText: String
    
    private var borderColor: Color {
        if disabled {
            .disabledBorder
        } else {
            .outline
        }
    }
    
    private var placeHolderColor: Color {
        if disabled {
            .disabledText
        } else {
            .onSurfaceVariant
        }
    }
    
    private var textColor: Color {
        if disabled {
            .disabledText
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
        leadingIcon: Image? = nil
    ) {
        self.initialText = initialText
        self.onTextChange = onTextChange
        self.placeHolder = placeHolder
        self.axis = axis
        self.disabled = disabled
        self.errorMessage = errorMessage
        self.leadingIcon = leadingIcon
        
        currentText = initialText
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center, spacing: Dimens.leadingIconSpacing) {
                leadingIcon?
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimens.inputIconSize, height: Dimens.inputIconSize)
                    .foregroundStyle(placeHolderColor)
                
                
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
                    .multilineTextAlignment(.leading)
            }
        }
        .onChange(of: currentText) {
            currentText = onTextChange($0)
        }
    }
}

struct OutlinedPasswordTextField: View {
    let label: String
    let text: String
    let onTextChange: (String) -> Void
    let isDisabled: Bool
    let errorMessage: String?
    
    @FocusState private var focusState: Field?
    private var field: Field?
    @State private var currentText: String = ""
    @State private var showPassword = false

    private var borderColor: Color {
       if isDisabled {
            .disabledBorder
        } else {
            .outline
        }
    }
    
    private var verticalPadding: CGFloat {
        showPassword ? 15.2 : 16
    }
    
    private var placeHolderColor: Color {
        if isDisabled {
            .disabledText
        } else {
            .onSurfaceVariant
        }
    }
    
    private var textColor: Color {
        if isDisabled {
            .disabledText
        } else {
            .primary
        }
    }
    
    init(
        label: String,
        text: String,
        onTextChange: @escaping (String) -> Void,
        isDisable: Bool = false,
        errorMessage: String? = nil
    ) {
        self.label = label
        self.text = text
        self.onTextChange = onTextChange
        self.isDisabled = isDisable
        self.errorMessage = errorMessage
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Group {
                    if showPassword {
                        TextField(
                            "",
                            text: Binding(
                                get: { text },
                                set: onTextChange
                            ),
                            prompt: Text(label).foregroundColor(placeHolderColor)
                        )
                    } else {
                        SecureField(
                            "",
                            text: Binding(
                                get: { text },
                                set: onTextChange
                            ),
                            prompt: Text(label).foregroundColor(placeHolderColor)
                        )
                    }
                }
                .foregroundColor(textColor)
                .textInputAutocapitalization(.never)
                .textContentType(.password)
                .focused($focusState, equals: field)
                
                Image(systemName: showPassword ? "eye" : "eye.slash")
                    .resizable()
                    .scaledToFit()
                    .frame(width: Dimens.inputIconSize, height: Dimens.inputIconSize)
                    .foregroundColor(placeHolderColor)
                    .onTapGesture {
                        showPassword.toggle()
                    }
            }
            .padding(.horizontal)
            .padding(.vertical, verticalPadding)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(borderColor, lineWidth: 2)
            )
            .cornerRadius(5)
            .disabled(isDisabled)
            
            if errorMessage != nil {
                Text(errorMessage!)
                    .font(.footnote)
                    .padding(.leading, Dimens.mediumPadding)
                    .foregroundColor(.red)
            }
        }
    }
}

extension OutlinedTextField {
    func setTextFieldFocusState(focusState: FocusState<Field?>, field: Field) -> Self {
        var copy = self
        copy._focusState = focusState
        copy.field = field
        return copy
    }
}

extension OutlinedPasswordTextField {
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

struct TransparentTextFieldArea: View {
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
    
    @State private var currentText: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $currentText)
            
            if currentText.isEmpty {
                Text(placeHolder)
                    .foregroundColor(.onSurfaceVariant)
                    .padding(.horizontal, Dimens.extraSmallPadding)
                    .padding(.vertical, Dimens.smallPadding)
            }
        }
        .onChange(of: currentText) {
            currentText = onTextChange($0)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        OutlinedTextField(
            initialText: "",
            onTextChange: { _ in "" },
            placeHolder: "Outlined text field"
        )
        
        OutlinedPasswordTextField(
            label: "Outlined password text field",
            text: "",
            onTextChange: { _ in },
            isDisable: false,
            errorMessage: nil
        )
        
        TransparentTextField(
            initialText: "",
            onTextChange: { _ in "" },
            placeHolder: "Transparent text field"
        )
        
        TransparentTextFieldArea(
            initialText: "",
            onTextChange: { _ in "" },
            placeHolder: "Transparent text field area"
        )
        .frame(maxWidth: .infinity, maxHeight: 200)
    }
}
