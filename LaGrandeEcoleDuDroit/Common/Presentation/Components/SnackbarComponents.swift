import SwiftUI

private let infoIconColor = Color("#3975EA")
private let successIconColor = Color("#55AB43")
private let errorIconColor = Color("#C65052")
private let warningIconColor = Color("#B79633")

struct InfoSnackbar: View {
    private let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    var body: some View {
        HStack {
            Image(systemName: "info.circle.fill")
                .foregroundColor(infoIconColor)
            Text(message)
                .foregroundColor(.inverseOnSurface)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.inverseSurface)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct SuccesSnackbar: View {
    private let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(successIconColor)
            Text(message)
                .foregroundColor(.inverseOnSurface)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.inverseSurface)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct ErrorSnackbar: View {
    private let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    var body: some View {
        HStack {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(errorIconColor)
            Text(message)
                .foregroundColor(.inverseOnSurface)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.inverseSurface)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

struct WarningSnackbar: View {
    private let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(warningIconColor)
            Text(message)
                .foregroundColor(.inverseOnSurface)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.inverseSurface)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

#Preview {
    VStack {
        InfoSnackbar("Info message")
        SuccesSnackbar("Success message")
        ErrorSnackbar("Error message")
        WarningSnackbar("Warning message")
    }
    .padding()
}
