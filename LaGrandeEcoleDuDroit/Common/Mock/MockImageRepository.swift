import Foundation

class MockImageRepository: ImageRepository {
    func uploadImage(imageData: Data, fileName: String) async throws {}
    
    func createLocalImage(imageData: Data, fileName: String) async throws {}
    
    func deleteRemoteImage(fileName: String) async throws {}
    
    func deleteLocalImage(fileName: String) async throws {}
}
