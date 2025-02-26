enum SnackBarType: Equatable {
    case info(_ message: String = "")
    case success(_ message: String = "")
    case error(_ message: String = "")
    case warning(_ message: String = "")
}
