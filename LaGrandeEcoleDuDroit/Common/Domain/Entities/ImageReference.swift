import Foundation

enum ImageReference {
    case imageUrl(String)
    case imagePath(String)
    case imageData(Data)
}
