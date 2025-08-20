import Foundation

protocol ImageApi {
    func uploadImage(imageData: Data, fileName: String) async throws -> (URLResponse, ServerResponse)
    
    func deleteImage(fileName: String) async throws -> (URLResponse, ServerResponse)
}
