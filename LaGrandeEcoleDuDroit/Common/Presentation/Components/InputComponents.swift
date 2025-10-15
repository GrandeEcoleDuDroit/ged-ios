import SwiftUI

struct OutlineTextField: View {
    let label: String
    @Binding var text: String
    let isDisabled: Bool
    let errorMessage: String?
    @FocusState var focusState: Field?
    let field: Field
    
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
        isDisable: Bool = false,
        errorMessage: String? = nil,
        focusState: FocusState<Field?>,
        field: Field
    ) {
        self.label = label
        self._text = text
        self.isDisabled = isDisable
        self.errorMessage = errorMessage
        self._focusState = focusState
        self.field = field
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField(
                "",
                text: $text,
                prompt: Text(label).foregroundColor(labelColor)
            )
            .foregroundStyle(textColor)
            .focused($focusState, equals: field)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(borderColor, lineWidth: 2)
            )
            .cornerRadius(5)
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

struct OutlinePasswordTextField: View {
    let label: String
    @Binding var text: String
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
        isDisable: Bool = false,
        errorMessage: String? = nil,
        focusState: FocusState<Field?>,
        field: Field
    ) {
        self.label = label
        self._text = text
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
                        text: $text,
                        prompt: Text(label).foregroundColor(labelColor)
                    )
                    .foregroundColor(textColor)
                    .textInputAutocapitalization(.never)
                    .textContentType(.password)
                    .focused($focusState, equals: field)
                    
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
                    .textContentType(.password)
                    .focused($focusState, equals: field)
                
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
            isDisable: false,
            errorMessage: nil,
            focusState: FocusState<Field?>(),
            field: .email
        )
        
        OutlinePasswordTextField(
            label: "Password",
            text: .constant(""),
            isDisable: false,
            errorMessage: nil,
            focusState: FocusState<Field?>(),
            field: .password
        )
    }.padding()
}
