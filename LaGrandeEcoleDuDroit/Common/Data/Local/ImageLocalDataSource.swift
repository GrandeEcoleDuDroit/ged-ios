import Foundation

class ImageLocalDataSource {
    func createLocalImage(folderName: String, fileName: String, imageData: Data) async throws -> String? {
        guard let folderUrl = getFolderUrl(folderName: folderName) else {
            return nil
        }
        
        if !FileManager.default.fileExists(atPath: folderUrl.path()) {
            try FileManager.default.createDirectory(
                at: folderUrl,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        
        let imageUrl = folderUrl.appendingPathComponent(fileName)
        try imageData.write(to: imageUrl)
        return imageUrl.path()
    }
    
    func deleteLocalImage(folderName: String, fileName: String) async throws {
        if let imageUrl = getFolderUrl(folderName: folderName)?.appendingPathComponent(fileName) {
            try FileManager.default.removeItem(at: imageUrl)
        }
    }
    
    private func getFolderUrl(folderName: String) -> URL? {
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )
        .first?.appendingPathComponent(folderName)
    }
}
