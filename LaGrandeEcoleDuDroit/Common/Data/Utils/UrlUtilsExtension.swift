extension UrlUtils {
    static func formatOracleBucketUrl(imagePath: String?) -> String? {
        guard let imagePath else { return nil }
        return GedConfiguration.oracleBucketUrl + "/" + imagePath
    }
}
