import Foundation

class MockImageRepository: ImageRepository {
    func uploadImage(imageData: Data, fileName: String) async throws {
        // Do nothing
    }
}
