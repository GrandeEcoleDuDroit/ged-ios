import SwiftUI

struct OutlineTextField: View {
    let label: String
    @Binding var text: String
    @Binding var focusedInputField: InputField?
    let inputField: InputField
    let isDisabled: Bool
    let errorMessage: String?
    @FocusState private var focusedField: InputField?
    
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
        if focusedField == inputField {
            4
        } else {
            2
        }
    }
    
    private var labelColor: Color {
        if isDisabled {
            .disableText
        } else {
            .outline
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
        text: Binding<String>,
        inputField: InputField,
        focusedInputField: Binding<InputField?>,
        isDisable: Bool = false,
        errorMessage: String? = nil
    ) {
        self.label = label
        self._text = text
        self.inputField = inputField
        self._focusedInputField = focusedInputField
        self.isDisabled = isDisable
        self.errorMessage = errorMessage
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField(
                "",
                text: $text,
                prompt: Text(label).foregroundColor(labelColor)
            )
            .foregroundStyle(textColor)
            .focused($focusedField, equals: inputField)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(borderColor, lineWidth: 2)
            )
            .cornerRadius(5)
            .onChange(of: focusedInputField) { newValue in
                focusedField = newValue
            }
            .disabled(isDisabled)
            .simultaneousGesture(TapGesture().onEnded({
                focusedInputField = self.inputField
            }))
            
            if errorMessage != nil {
                Text(errorMessage!)
                    .padding(.leading, GedSpacing.medium)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

struct OutlinePasswordTextField: View {
    let label: String
    @Binding var text: String
    @Binding var focusedInputField: InputField?
    let inputField: InputField
    let isDisabled: Bool
    @State private var showPassword = false
    @FocusState private var focusedField: InputField?
    let errorMessage: String?

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
        if focusedField == inputField {
            2
        } else {
            1
        }
    }
    
    private var verticalPadding: CGFloat {
        showPassword ? 15.5 : 16
    }
    
    private var labelColor: Color {
        if isDisabled {
            .disableText
        } else {
            .outline
        }
    }
    
    private var textColor: Color {
        if isDisabled {
            .gray
        } else {
            .primary
        }
    }
    
    init(
        label: String,
        text: Binding<String>,
        inputField: InputField,
        focusedInputField: Binding<InputField?>,
        isDisable: Bool = false,
        errorMessage: String? = nil
    ) {
        self.label = label
        self._text = text
        self.inputField = inputField
        self._focusedInputField = focusedInputField
        self.isDisabled = isDisable
        self.errorMessage = errorMessage
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if(!showPassword) {
                    SecureField(
                        "",
                        text: $text,
                        prompt: Text(label).foregroundColor(labelColor)
                    )
                    .foregroundColor(textColor)
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: inputField)
                    .onChange(of: focusedInputField) { newValue in
                        focusedField = newValue
                    }
                    .simultaneousGesture(TapGesture().onEnded({
                        focusedInputField = self.inputField
                    }))
                    
                    Image(systemName: "eye.slash")
                        .foregroundColor(.iconInput)
                        .onTapGesture {
                            showPassword = true
                        }
                } else {
                    TextField(
                        "",
                        text: $text,
                        prompt: Text(label).foregroundColor(labelColor)
                    )
                    .foregroundColor(textColor)
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: inputField)
                    .onChange(of: focusedInputField) { newValue in
                        focusedField = newValue
                    }
                    .simultaneousGesture(TapGesture().onEnded({
                        focusedInputField = self.inputField
                    }))
                
                    Image(systemName: "eye")
                        .foregroundColor(.iconInput)
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
                    .padding(.leading, GedSpacing.medium)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    VStack(spacing: GedSpacing.large) {
        OutlineTextField(
            label: "Email",
            text: .constant(""),
            inputField: InputField.email,
            focusedInputField: .constant(InputField.email),
            isDisable: false,
            errorMessage: nil
        )
        
        OutlinePasswordTextField(
            label: "Password",
            text: .constant(""),
            inputField: InputField.password,
            focusedInputField: .constant(InputField.password),
            isDisable: false,
            errorMessage: nil
        )
    }.padding()
}
