import Foundation

class FileStorageService {
    func getImage(path: String) async throws -> Data? {
        if FileManager.default.fileExists(atPath: path) {
            try Data(contentsOf: URL(fileURLWithPath: path))
        } else {
            nil
        }
    }
    
    func storeImage(data: Data, path: String) async throws {
        guard let url = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask,
        ).first?.appendingPathComponent(path) else {
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
        
        try data.write(to: url)
    }
    
    func deleteImage(path: String) async throws {
        if FileManager.default.fileExists(atPath: path) {
            try FileManager.default.removeItem(atPath: path)
        }
    }
}
