import SwiftUI

let serverBaseUrl = ""

func getString(gedString: String) -> String {
    return NSLocalizedString(gedString, comment: "")
}

func getString(gedString: String, _ args: CVarArg...) -> String {
    let value = NSLocalizedString(gedString, comment: "")
    return String(format: value, arguments: args)
}

func verifyEmail(_ email: String) -> Bool {
    let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Z|a-z]{2,}"
    let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    return emailPredicate.evaluate(with: email)
}
