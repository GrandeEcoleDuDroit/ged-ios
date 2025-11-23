import Foundation

class ImageLocalDataSource {
    func createLocalImage(imageData: Data?, fileName: String) async throws {
        try createFolderIfNeeded()
        guard let localImageUrl = localImageUrl(fileName: fileName) else { return }
        try imageData?.write(to: localImageUrl)
    }
    
    func deleteLocalImage(fileName: String) async throws {
        if let localImageUrl = localImageUrl(fileName: fileName) {
            try FileManager.default.removeItem(at: localImageUrl)
        }
    }
    
    private func createFolderIfNeeded() throws {
        guard let folderUrl = localFolderUrl() else { return }
        if !FileManager.default.fileExists(atPath: folderUrl.path) {
            try FileManager.default.createDirectory(at: folderUrl, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    private func localImageUrl(fileName: String) -> URL? {
        guard let localFolderUrl = localFolderUrl() else { return nil }
        return localFolderUrl.appendingPathComponent(fileName)
    }
    
    private func localFolderUrl() -> URL? {
        let folderName: String = "GedImages_Local"
        guard let localStorageUrl = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else { return nil }
        
        return localStorageUrl.appendingPathComponent(folderName)
    }
}
