import SwiftUI

struct EmailTextField: View {
    let title: String
    @Binding var text: String
    @Binding var inputFieldFocused: InputField?
    let inputField: InputField
    let isDisabled: Bool
    
    private var borderColor: Color {
        if isDisabled == false {
            Color.black
        } else {
            Color.gray
        }
    }
    
    @FocusState private var focusedField: InputField?
    
    init(
        title: String,
        text: Binding<String>,
        inputField: InputField,
        inputFieldFocused: Binding<InputField?>,
        isDisable: Bool = false
    ) {
        self.title = title
        self._text = text
        self.inputField = inputField
        self._inputFieldFocused = inputFieldFocused
        self.isDisabled = isDisable
    }
    
    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(title).foregroundColor(.inputHint)
        )
        .textInputAutocapitalization(.never)
        .focused($focusedField, equals: inputField)
        .padding()
        .background(.inputBackground)
        .cornerRadius(10)
        .onChange(of: inputFieldFocused) { newValue in
            focusedField = newValue
        }
        .disabled(isDisabled)
        .simultaneousGesture(TapGesture().onEnded({
            inputFieldFocused = self.inputField
        }))
    }
}

struct PasswordTextField: View {
    let title: String
    @Binding var text: String
    @Binding var inputFieldFocused: InputField?
    let inputField: InputField
    let isDisabled: Bool
    
    private var borderColor: Color {
        if isDisabled == false {
            Color.black
        } else {
            Color.gray
        }
    }
    private var borderWidth: CGFloat = 0.5
    private var cornerRadius: CGFloat = 5
    @State private var showPassword = false
    @State private var padding: CGFloat = 16
    @FocusState private var focusedField: InputField?
    
    init(
        title: String,
        text: Binding<String>,
        inputField: InputField,
        inputFieldFocused: Binding<InputField?>,
        isDisable: Bool = false
    ) {
        self.title = title
        self._text = text
        self.inputField = inputField
        self._inputFieldFocused = inputFieldFocused
        self.isDisabled = isDisable
    }
    
    var body: some View {
        HStack {
            if(!showPassword) {
                SecureField("", text: $text, prompt: Text(title).foregroundColor(.inputHint))
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: inputField)
                    .onChange(of: inputFieldFocused) { newValue in
                        focusedField = newValue
                    }
                    .simultaneousGesture(TapGesture().onEnded({
                        inputFieldFocused = self.inputField
                    }))
                
                Image(systemName: "eye.slash")
                    .foregroundColor(.iconInput)
                    .onTapGesture {
                        padding = 16
                        showPassword = true
                        DispatchQueue.main.async {
                            focusedField = inputField
                        }
                    }
            } else {
                TextField(title, text: $text, prompt: Text(title).foregroundColor(.inputHint))
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: inputField)
                    .onChange(of: inputFieldFocused) { newValue in
                        focusedField = newValue
                    }
                    .simultaneousGesture(TapGesture().onEnded({
                        inputFieldFocused = self.inputField
                    }))
                
                Image(systemName: "eye")
                    .foregroundColor(.iconInput)
                    .onTapGesture {
                        padding = 16.5
                        showPassword = false
                        DispatchQueue.main.async {
                            focusedField = inputField
                        }
                    }
            }
        }
        .padding(padding)
        .background(.inputBackground)
        .cornerRadius(10)
        .disabled(isDisabled)
    }
}

#Preview {
    VStack(spacing: GedSpacing.large) {
        EmailTextField(
            title: "Email",
            text: .constant(""),
            inputField: InputField.email,
            inputFieldFocused: .constant(InputField.email),
            isDisable: false
        )
        
        PasswordTextField(
            title: "Password",
            text: .constant(""),
            inputField: InputField.password,
            inputFieldFocused: .constant(InputField.password),
            isDisable: false
        )
    }.padding()
}
