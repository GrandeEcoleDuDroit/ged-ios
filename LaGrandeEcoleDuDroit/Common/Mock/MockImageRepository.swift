import Foundation

class MockImageRepository: ImageRepository {
    func createLocalImage(imageData: Data, folderName: String, fileName: String) async throws -> String? { nil }

    func uploadImage(imageData: Data, fileName: String) async throws {}

    func deleteRemoteImage(fileName: String) async throws {}
    
    func deleteLocalImage(folderName: String, fileName: String) async throws {}
}
