import Foundation

enum ImageReference {
    case imageUrl(String)
    case imagePath(String)
    case imageData(Data)
    
    var value: String? {
        switch self {
            case let .imageUrl(value): value
            case let .imagePath(value): value
            case let .imageData(value): String(data: value, encoding: .utf8)
        }
    }
}
