import SwiftUI

struct FocusableOutlinedTextField: View {
    let title: String
    @Binding var text: String
    @Binding var inputState: InputField?
    let focusValue: InputField
    @Binding var isDisabled: Bool
    
    private var borderColor: Color {
        isDisabled ? Color.gray : Color.black
    }

    private var borderWidth: CGFloat = 1
    private var cornerRadius: CGFloat = 5
    @FocusState private var focusedField: InputField?
    
    init(
        title: String,
        text: Binding<String>,
        focusValue: InputField,
        inputState: Binding<InputField?>,
        isDisable: Binding<Bool>
    ) {
        self.title = title
        self._text = text
        self.focusValue = focusValue
        self._inputState = inputState
        self._isDisabled = isDisable
    }
    
    var body: some View {
        TextField(title, text: $text)
            .tint(Color(GedColor.primary))
            .focused($focusedField, equals: focusValue)
            .textInputAutocapitalization(.never)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .cornerRadius(cornerRadius)
            .onChange(of: inputState) { newValue in
                focusedField = newValue
            }
            .disabled(isDisabled)
    }
}

struct FocusableOutlinedPasswordTextField: View {
    let title: String
    @Binding var text: String
    @Binding var inputState: InputField?
    let focusValue: InputField
    @Binding var isDisabled: Bool
    
    private var borderColor: Color {
        isDisabled ? Color.gray : Color.black
    }
    private var borderWidth: CGFloat = 0.7
    private var cornerRadius: CGFloat = 5
    @State private var showPassword = false
    @State private var padding: CGFloat = 16
    @FocusState private var focusedField: InputField?
    
    var body: some View {
        HStack {
            if(!showPassword) {
                SecureField(title, text: $text)
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: focusValue)
                    .onChange(of: inputState) { newValue in
                        focusedField = newValue
                    }
                Image(systemName: "eye.slash")
                    .onTapGesture {
                        padding = 16
                        showPassword = true
                        DispatchQueue.main.async {
                            focusedField = focusValue
                        }
                    }
            } else {
                TextField(title, text: $text)
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: focusValue)
                    .onChange(of: inputState) { newValue in
                        focusedField = newValue
                    }
                Image(systemName: "eye")
                    .onTapGesture {
                        padding = 16.6
                        showPassword = false
                        DispatchQueue.main.async {
                            focusedField = focusValue
                        }
                    }
            }
        }
        .tint(Color(GedColor.primary))
        .padding(padding)
        .cornerRadius(cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(borderColor, lineWidth: borderWidth)
        )
        .disabled(isDisabled)
    }
    
    init(
        title: String,
        text: Binding<String>,
        focusValue: InputField,
        inputState: Binding<InputField?>,
        isDisable: Binding<Bool>
    ) {
        self.title = title
        self._text = text
        self.focusValue = focusValue
        self._inputState = inputState
        self._isDisabled = isDisable
    }
}

#Preview {
    VStack {
        FocusableOutlinedTextField(
            title: "Email",
            text: .constant(""),
            focusValue: InputField.email,
            inputState: .constant(InputField.email),
            isDisable: .constant(false)
        )
        
        FocusableOutlinedPasswordTextField(
            title: "Password",
            text: .constant(""),
            focusValue: InputField.password,
            inputState: .constant(InputField.password),
            isDisable: .constant(false)
        )
    }.padding()
}
