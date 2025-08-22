import Foundation

protocol ImageApi {
    func downloadImage(url: String) async throws -> Data?

    func uploadImage(imageData: Data, fileName: String) async throws -> (URLResponse, ServerResponse)
    
    func deleteImage(fileName: String) async throws -> (URLResponse, ServerResponse)
}
