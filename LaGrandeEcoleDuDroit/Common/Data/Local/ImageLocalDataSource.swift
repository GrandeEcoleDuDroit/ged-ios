import Foundation

class ImageLocalDataSource {
    func createLocalImage(imageData: Data, imagePath: String) async throws {
        guard let url = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask,
        ).first?.appendingPathComponent(imagePath) else {
            return
        }
        
        let directoryUrl = url.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directoryUrl.path()) {
            try FileManager.default.createDirectory(
                at: url,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
        
        try imageData.write(to: url)
    }
    
    func deleteLocalImage(imagePath: String) async throws {
        if FileManager.default.fileExists(atPath: imagePath) {
            try FileManager.default.removeItem(atPath: imagePath)
        }
    }
}
