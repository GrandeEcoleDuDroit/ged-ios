struct CommonPresentationUtils {
    private init() {}
    
    static let maxImageFileSize: Int64 = 3 * 1024 * 1024
    
    static func imageTooLargeErrorMessage(maxSize: Int64 = maxImageFileSize) -> String {
        stringResource(.imageTooLargeErrorMessage, maxSize.formatted(.byteCount(style: .binary)))
    }
    
    static func loremIpsum(n: Int = 1) -> String {
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua." +
        "Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat." +
        "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur." +
        "Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.".repeatText(n)
    }
}
