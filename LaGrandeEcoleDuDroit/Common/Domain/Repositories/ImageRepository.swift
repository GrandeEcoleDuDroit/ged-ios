import Foundation

protocol ImageRepository {
    func createLocalImage(imageData: Data, folderName: String, fileName: String) async throws -> String? 

    func uploadImage(imageData: Data, fileName: String) async throws
        
    func deleteRemoteImage(fileName: String) async throws
    
    func deleteLocalImage(folderName: String, fileName: String) async throws
}
