import SwiftUI

func getString(gedString: String) -> String {
    return NSLocalizedString(gedString, comment: "")
}

func getString(gedString: String, _ args: CVarArg...) -> String {
    let value = NSLocalizedString(gedString, comment: "")
    return String(format: value, arguments: args)
}
