import Foundation

class ImageLocalDataSource {
    func getImage(imagePath: String) async throws -> Data? {
        if FileManager.default.fileExists(atPath: imagePath) {
            try Data(contentsOf: URL(fileURLWithPath: imagePath))
        } else {
            nil
        }
    }
    
    func createImage(imageData: Data, imagePath: String) async throws {
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
    
    func deleteImage(imagePath: String) async throws {
        if FileManager.default.fileExists(atPath: imagePath) {
            try FileManager.default.removeItem(atPath: imagePath)
        }
    }
}
