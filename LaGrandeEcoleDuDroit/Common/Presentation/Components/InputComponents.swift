import SwiftUI

struct FillTextField: View {
    let title: String
    @Binding var text: String
    @Binding var inputFieldFocused: InputField?
    let inputField: InputField
    let isDisabled: Bool
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
            prompt: Text(title).foregroundColor(.secondary)
        )
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

struct FillPasswordTextField: View {
    let title: String
    @Binding var text: String
    @Binding var inputFieldFocused: InputField?
    let inputField: InputField
    let isDisabled: Bool
    @State private var showPassword = false
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
                SecureField(
                    "",
                    text: $text,
                    prompt: Text(title).foregroundColor(.secondary)
                )
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
                        showPassword = true
                    }
            } else {
                TextField(title, text: $text, prompt: Text(title).foregroundColor(.secondary))
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
                        showPassword = false
                    }
            }
        }
        .padding(16)
        .background(.inputBackground)
        .cornerRadius(10)
        .disabled(isDisabled)
    }
}

#Preview {
    VStack(spacing: GedSpacing.large) {
        FillTextField(
            title: "Email",
            text: .constant(""),
            inputField: InputField.email,
            inputFieldFocused: .constant(InputField.email),
            isDisable: false
        )
        
        FillPasswordTextField(
            title: "Password",
            text: .constant(""),
            inputField: InputField.password,
            inputFieldFocused: .constant(InputField.password),
            isDisable: false
        )
    }.padding()
}
