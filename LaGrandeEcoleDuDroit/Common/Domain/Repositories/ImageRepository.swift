import Foundation

protocol ImageRepository {
    func createLocalImage(imageData: Data, fileName: String) async throws

    func uploadImage(imageData: Data, fileName: String) async throws
        
    func deleteRemoteImage(fileName: String) async throws
    
    func deleteLocalImage(fileName: String) async throws
}
