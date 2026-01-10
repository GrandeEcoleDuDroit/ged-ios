import SwiftUI

struct OutlinedTextField<FocusField: Hashable>: View {
    private let placeHolder: String
    @Binding private var text: String
    private let axis: Axis
    private let disabled: Bool
    private let errorMessage: String?
    private let leadingIcon: Image?
    
    @FocusState private var focusState: FocusField?
    private var field: FocusField?
    
    init(
        _ placeHolder: String,
        text: Binding<String>,
        axis: Axis = .horizontal,
        disabled: Bool = false,
        errorMessage: String? = nil,
        leadingIcon: Image? = nil
    ) where FocusField == Never {
        self.placeHolder = placeHolder
        self._text = text
        self.axis = axis
        self.disabled = disabled
        self.errorMessage = errorMessage
        self.leadingIcon = leadingIcon
    }
    
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
    
    private var prompt: Text {
        if #available(iOS 17.0, *) {
            Text(placeHolder).foregroundStyle(placeHolderColor)
        } else {
            Text(placeHolder).foregroundColor(placeHolderColor)
        }
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
                    text: $text,
                    prompt: prompt,
                )
                .foregroundStyle(textColor)
                .focused($focusState, equals: field)
            }
            .outlined(borderColor: borderColor)
            .disabled(disabled)
            
            if errorMessage != nil {
                Text(errorMessage!)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, Dimens.mediumPadding)
                    .foregroundStyle(.red)
            }
        }
    }
}

extension OutlinedTextField {
    init(
        _ placeHolder: String,
        text: Binding<String>,
        axis: Axis = .horizontal,
        disabled: Bool = false,
        errorMessage: String? = nil,
        leadingIcon: Image? = nil,
        focusState: FocusState<FocusField?>,
        field: FocusField
    ) {
        self.placeHolder = placeHolder
        self._text = text
        self.axis = axis
        self.disabled = disabled
        self.errorMessage = errorMessage
        self.leadingIcon = leadingIcon
        self._focusState = focusState
        self.field = field
    }
}

struct OutlinedPasswordTextField<FocusField: Hashable>: View {
    private let placeHolder: String
    @Binding private var text: String
    private let disabled: Bool
    private let errorMessage: String?
    private let supportingText: String?
    
    @FocusState private var focusState: FocusField?
    private var field: FocusField?
    @State private var showPassword = false
    
    init(
        _ placeHolder: String,
        text: Binding<String>,
        disabled: Bool = false,
        errorMessage: String? = nil,
        supportingText: String? = nil
    ) where FocusField == Never {
        self.placeHolder = placeHolder
        self._text = text
        self.disabled = disabled
        self.errorMessage = errorMessage
        self.supportingText = supportingText
    }

    private var borderColor: Color {
       if disabled {
            .disabledBorder
        } else {
            .outline
        }
    }
    
    private var verticalPadding: CGFloat {
        showPassword ? 15.2 : 16
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
    
    private var prompt: Text {
        if #available(iOS 17.0, *) {
            Text(placeHolder).foregroundStyle(placeHolderColor)
        } else {
            Text(placeHolder).foregroundColor(placeHolderColor)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Group {
                    if showPassword {
                        TextField(
                            "",
                            text: $text,
                            prompt: prompt
                        )
                    } else {
                        SecureField(
                            "",
                            text: $text,
                            prompt: prompt
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
            .disabled(disabled)
            
            if let supportingText {
                Text(supportingText)
                    .font(.caption)
                    .foregroundStyle(.informationText)
                    .padding(.leading, Dimens.mediumPadding)
                    .multilineTextAlignment(.leading)
            }
            
            if errorMessage != nil {
                Text(errorMessage!)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
                    .padding(.leading, Dimens.mediumPadding)
                    .foregroundStyle(.red)
            }
        }
    }
}

extension OutlinedPasswordTextField {
    init(
        _ placeHolder: String,
        text: Binding<String>,
        disabled: Bool = false,
        errorMessage: String? = nil,
        focusState: FocusState<FocusField?>,
        field: FocusField
    ) {
        self.placeHolder = placeHolder
        self._text = text
        self.disabled = disabled
        self.errorMessage = errorMessage
        self._focusState = focusState
        self.field = field
        self.supportingText = nil
    }
}

struct TransparentTextField<FocusField: Hashable>: View {
    private let placeHolder: String
    @Binding private var text: String
    
    @FocusState private var focusState: FocusField?
    private var field: FocusField?
    
    init(
        _ placeHolder: String,
        text: Binding<String>,
    ) where FocusField == Never {
        self.placeHolder = placeHolder
        self._text = text
    }
    
    private var prompt: Text {
        if #available(iOS 17.0, *) {
            Text(placeHolder).foregroundStyle(.onSurfaceVariant)
        } else {
            Text(placeHolder).foregroundColor(.onSurfaceVariant)
        }
    }
    
    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: prompt,
            axis: .vertical
        )
        .focused($focusState, equals: field)
    }
}

extension TransparentTextField {
    init(
        _ placeHolder: String,
        text: Binding<String>,
        focusState: FocusState<FocusField?>,
        field: FocusField
    ) {
        self.placeHolder = placeHolder
        self._text = text
        self._focusState = focusState
        self.field = field
    }
}

struct TransparentTextFieldArea<FocusField: Hashable>: View {
    private let placeHolder: String
    @Binding private var text: String
    
    @FocusState private var focusState: FocusField?
    private var field: FocusField?
    
    init(
        _ placeHolder: String,
        text: Binding<String>
    ) where FocusField == Never {
        self.placeHolder = placeHolder
        self._text = text
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .scrollContentBackground(.hidden)
                .focused($focusState, equals: field)
            
            if text.isEmpty {
                Text(placeHolder)
                    .foregroundColor(.onSurfaceVariant)
                    .padding(.horizontal, 5)
                    .padding(.vertical, Dimens.smallPadding)
            }
        }
    }
}

extension TransparentTextFieldArea {
    init(
        _ placeHolder: String,
        text: Binding<String>,
        focusState: FocusState<FocusField?>,
        field: FocusField
    ) {
        self.placeHolder = placeHolder
        self._text = text
        self._focusState = focusState
        self.field = field
    }
}

#Preview {
    VStack(spacing: 20) {
        OutlinedTextField(
            "Outlined text field",
            text: .constant("")
        )
        
        OutlinedPasswordTextField(
            "Outlined password text field",
            text: .constant(""),
            disabled: false,
            errorMessage: nil
        )
        
        TransparentTextField(
            "Transparent text field",
            text: .constant("")
        )
        
        TransparentTextFieldArea(
            "Transparent text field area",
            text: .constant("")
        )
        .frame(maxWidth: .infinity, maxHeight: 200)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding(.horizontal)
    .background(.appBackground)
}
