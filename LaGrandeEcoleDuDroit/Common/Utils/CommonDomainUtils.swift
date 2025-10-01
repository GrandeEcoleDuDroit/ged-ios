import Foundation

func getString(_ gedString: GedString) -> String {
    NSLocalizedString(gedString.rawValue, comment: "")
}

func getString(_ gedString: GedString, _ args: CVarArg...) -> String {
    let value = NSLocalizedString(gedString.rawValue, comment: "")
    return String(format: value, arguments: args)
}

func sleep(_ seconds: Float) async {
    try? await Task.sleep(nanoseconds: UInt64(seconds) * 1_000_000_000)
}
