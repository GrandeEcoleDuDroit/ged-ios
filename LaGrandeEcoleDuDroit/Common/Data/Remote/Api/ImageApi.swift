import Foundation

protocol ImageApi {
    func uploadImage(imageData: Data, imagePath: String) async throws -> (URLResponse, ServerResponse)

    func deleteImage(imagePath: String) async throws -> (URLResponse, ServerResponse)
}
