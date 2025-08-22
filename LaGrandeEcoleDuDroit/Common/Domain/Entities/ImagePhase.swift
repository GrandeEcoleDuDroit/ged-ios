import Foundation

enum ImagePhase {
    case empty
    case loading
    case success(Data)
    case failure
}
