import Foundation

func stringResource(_ value: Strings) -> String {
    NSLocalizedString(value.rawValue, comment: "")
}

func stringResource(_ value: Strings, _ args: CVarArg...) -> String {
    String(
        format: NSLocalizedString(value.rawValue, comment: ""),
        arguments: args
    )
}
