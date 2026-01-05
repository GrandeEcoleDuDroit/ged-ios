import Foundation

extension Data {
    func imageExtension() -> String? {
        if self.starts(with: [0x89, 0x50, 0x4E, 0x47]) {
            return "png"
        }

        if self.starts(with: [0xFF, 0xD8]) {
            return "jpeg"
        }

        if self.starts(with: [0x47, 0x49, 0x46]) {
            return "gif"
        }

        if self.count > 12 {
            let riff = self.prefix(4)
            let webp = self[8..<12]
            if riff.elementsEqual([0x52, 0x49, 0x46, 0x46]) &&
               webp.elementsEqual([0x57, 0x45, 0x42, 0x50]) {
                return "webp"
            }
        }
        
        return nil
    }
}
