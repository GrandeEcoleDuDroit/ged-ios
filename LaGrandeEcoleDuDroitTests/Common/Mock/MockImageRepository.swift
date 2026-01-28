import Foundation

class MockImageRepository: ImageRepository {
    func getLocalImage(imagePath: String) async throws -> Data? { nil }

    func createLocalImage(imageData: Data, imagePath: String) async throws {}

    func deleteLocalImage(imagePath: String) async throws {}
}
