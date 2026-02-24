struct CommonPresentationUtils {
    private init() {}
    
    static let maxImageFileSize: Int64 = 3 * 1024 * 1024
    
    static func imageTooLargeErrorMessage(maxSize: Int64 = maxImageFileSize) -> String {
        stringResource(.imageTooLargeErrorMessage, maxSize.formatted(.byteCount(style: .binary)))
    }
}
