import Foundation

protocol ImageRepository {
    func createLocalImage(imageData: Data, imagePath: String) async throws

    func uploadImage(imageData: Data, imagePath: String) async throws
        
    func deleteRemoteImage(imagePath: String) async throws
    
    func deleteLocalImage(imagePath: String) async throws
}
