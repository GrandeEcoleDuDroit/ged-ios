import Foundation

enum ImagePhase: Codable, Hashable {
    case empty
    case loading
    case success(Data)
    case failure
}
