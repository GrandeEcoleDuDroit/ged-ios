import Foundation

protocol ImageApi {
    func uploadImage(imageData: Data, fileName: String) async throws
}
