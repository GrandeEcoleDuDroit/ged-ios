struct CommonUtilsPresentation {
    private init() {}
    
    static let maxImageFileSize: Int = 3 * 1024 * 1024
    static let maxImageFileSizeString: String = "3 \(stringResource(.mb))"
}
