import SwiftUI

struct FocusableOutlinedTextField: View {
    let title: String
    @Binding var text: String
    @Binding var inputFocused: InputField?
    let defaultFocusValue: InputField
    let isDisabled: Bool
    
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
        isDisable: Bool = false
    ) {
        self.title = title
        self._text = text
        self.defaultFocusValue = defaultFocusValue
        self._inputFocused = inputFocused
        self.isDisabled = isDisable
    }
    
    var body: some View {
        TextField(title, text: $text)
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
        defaultFocusValue: InputField,
        inputFocused: Binding<InputField?>,
        isDisable: Bool = false
    ) {
        self.title = title
        self._text = text
        self.defaultFocusValue = defaultFocusValue
        self._inputFocused = inputFocused
        self.isDisabled = isDisable
    }
    
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
                        padding = 16.5
                        showPassword = false
                        DispatchQueue.main.async {
                            focusedField = defaultFocusValue
                        }
                    }
            }
        }
        .padding(padding)
        .cornerRadius(cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(borderColor, lineWidth: borderWidth)
        )
        .disabled(isDisabled)
    }
}

struct DynamicTextEditor: View {
    @Binding var text: String
    private let placeholderText: Text
    private let minHeight: CGFloat
    private let maxHeight: CGFloat?
    
    init(
        text: Binding<String>,
        placeholderText: Text,
        minHeight: CGFloat = 100,
        maxHeight: CGFloat? = nil
    ) {
        self._text = text
        self.placeholderText = placeholderText
        self.minHeight = minHeight
        self.maxHeight = maxHeight
    }
    
    var body: some View {
        TextEditor(text: $text)
            .overlay {
                if text.isBlank {
                    if #available (iOS 17.0, *) {
                        placeholderText
                            .foregroundStyle(.gray)
                            .padding(.top, GedSpacing.small)
                            .padding(.leading, 6)
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .topLeading
                            )
                    } else {
                        placeholderText
                            .foregroundColor(.gray)
                            .padding(.top, GedSpacing.small)
                            .padding(.leading, 6)
                            .frame(
                                maxWidth: .infinity,
                                maxHeight: .infinity,
                                alignment: .topLeading
                            )
                    }
                }
            }
            .frame(minHeight: minHeight, maxHeight: maxHeight)
            .fixedSize(horizontal: false, vertical: true)
    }
}

#Preview {
    VStack(spacing: GedSpacing.large) {
        FocusableOutlinedTextField(
            title: "Email",
            text: .constant(""),
            defaultFocusValue: InputField.email,
            inputFocused: .constant(InputField.email),
            isDisable: false
        )
        
        FocusableOutlinedPasswordTextField(
            title: "Password",
            text: .constant(""),
            defaultFocusValue: InputField.password,
            inputFocused: .constant(InputField.password),
            isDisable: false
        )
        
        DynamicTextEditor(
            text: .constant(""),
            placeholderText: Text("Placeholder"),
            minHeight: 100,
            maxHeight: 300
        )
        .border(.gray)
    }.padding()
}
