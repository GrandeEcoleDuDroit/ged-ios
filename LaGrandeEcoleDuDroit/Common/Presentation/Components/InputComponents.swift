import SwiftUI

struct FocusableOutlinedTextField: View {
    let title: String
    @Binding var text: String
    @Binding var inputFocused: InputField?
    let defaultFocusValue: InputField
    @Binding var isDisabled: Bool
    
    private var borderColor: Color {
        if isDisabled == false {
            Color.black
        } else {
            Color.gray
        }
    }

    private var borderWidth: CGFloat = 1
    private var cornerRadius: CGFloat = 5
    @FocusState private var focusedField: InputField?
    
    init(
        title: String,
        text: Binding<String>,
        defaultFocusValue: InputField,
        inputFocused: Binding<InputField?>,
        isDisable: Binding<Bool>? = nil
    ) {
        self.title = title
        self._text = text
        self.defaultFocusValue = defaultFocusValue
        self._inputFocused = inputFocused
        self._isDisabled = isDisable ?? .constant(false)
    }
    
    var body: some View {
        TextField(title, text: $text)
            .tint(Color(GedColor.primary))
            .focused($focusedField, equals: defaultFocusValue)
            .textInputAutocapitalization(.never)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .cornerRadius(cornerRadius)
            .onChange(of: inputFocused) { newValue in
                focusedField = newValue
            }
            .disabled(isDisabled)
            .simultaneousGesture(TapGesture().onEnded({
                inputFocused = self.defaultFocusValue
            }))
    }
}

struct FocusableOutlinedPasswordTextField: View {
    let title: String
    @Binding var text: String
    @Binding var inputFocused: InputField?
    let defaultFocusValue: InputField
    @Binding var isDisabled: Bool
    
    private var borderColor: Color {
        if isDisabled == false {
            Color.black
        } else {
            Color.gray
        }
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
                    .focused($focusedField, equals: defaultFocusValue)
                    .onChange(of: inputFocused) { newValue in
                        focusedField = newValue
                    }
                    .simultaneousGesture(TapGesture().onEnded({
                        inputFocused = self.defaultFocusValue
                    }))
                Image(systemName: "eye.slash")
                    .onTapGesture {
                        padding = 16
                        showPassword = true
                        DispatchQueue.main.async {
                            focusedField = defaultFocusValue
                        }
                    }
            } else {
                TextField(title, text: $text)
                    .textInputAutocapitalization(.never)
                    .focused($focusedField, equals: defaultFocusValue)
                    .onChange(of: inputFocused) { newValue in
                        focusedField = newValue
                    }
                    .simultaneousGesture(TapGesture().onEnded({
                        inputFocused = self.defaultFocusValue
                    }))
                Image(systemName: "eye")
                    .onTapGesture {
                        padding = 16.4
                        showPassword = false
                        DispatchQueue.main.async {
                            focusedField = defaultFocusValue
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
        defaultFocusValue: InputField,
        inputFocused: Binding<InputField?>,
        isDisable: Binding<Bool>? = nil
    ) {
        self.title = title
        self._text = text
        self.defaultFocusValue = defaultFocusValue
        self._inputFocused = inputFocused
        self._isDisabled = isDisable ?? .constant(false)
    }
}

#Preview {
    VStack {
        FocusableOutlinedTextField(
            title: "Email",
            text: .constant(""),
            defaultFocusValue: InputField.email,
            inputFocused: .constant(InputField.email),
            isDisable: .constant(false)
        )
        
        FocusableOutlinedPasswordTextField(
            title: "Password",
            text: .constant(""),
            defaultFocusValue: InputField.password,
            inputFocused: .constant(InputField.password),
            isDisable: .constant(false)
        )
    }.padding()
}
