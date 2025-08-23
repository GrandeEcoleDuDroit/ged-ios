import Foundation

class ImageLocalDataSource {
    private let imageCache: NSCache<NSString, NSData>
    
    init() {
        let cache = NSCache<NSString, NSData>()
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB
        self.imageCache = cache
    }
    
    func saveImage(_ data: Data, forKey key: String) {
        imageCache.setObject(data as NSData, forKey: key as NSString)
    }

    func loadImage(forKey key: String) -> Data? {
        imageCache.object(forKey: key as NSString) as Data?
    }
    
    func removeImage(forKey key: String) {
        imageCache.removeObject(forKey: key as NSString)
    }

    func clearCache() {
        imageCache.removeAllObjects()
    }
}
