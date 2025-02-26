import Foundation

protocol ImageRepository {
    func uploadImage(imageData: Data, fileName: String) async throws
}
