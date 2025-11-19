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

func sleep(_ seconds: Float) async {
    try? await Task.sleep(nanoseconds: UInt64(seconds) * 1_000_000_000)
}
