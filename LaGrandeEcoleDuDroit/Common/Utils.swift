import Foundation

func getString(_ gedString: GedString) -> String {
    NSLocalizedString(gedString.rawValue, comment: "")
}

func getString(_ gedString: GedString, _ args: CVarArg...) -> String {
    let value = NSLocalizedString(gedString.rawValue, comment: "")
    return String(format: value, arguments: args)
}
