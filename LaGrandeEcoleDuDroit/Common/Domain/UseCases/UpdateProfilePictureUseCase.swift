import Foundation

class UpdateProfilePictureUseCase {
    private let userRepository: UserRepository
    private let imageRepository: ImageRepository
    
    init(
        userRepository: UserRepository,
        imageRepository: ImageRepository
    ) {
        self.userRepository = userRepository
        self.imageRepository = imageRepository
    }
    
    func execute(imageData: Data) async throws {
        guard let currentUser = userRepository.currentUser.value else {
            throw UserError.currentUserNotFound
        }
        
        let currentTime = Int64(Date().timeIntervalSince1970 * 1000)
        let fileType = getImageType(from: imageData)
        let fileName = "\(currentUser.id)-profile-picture-\(currentTime).\(fileType)"
        
        try await imageRepository.uploadImage(imageData: imageData, fileName: fileName)
        try await userRepository.updateProfilePictureUrl(userId: currentUser.id, profilePictureFileName: fileName)
    }
    
    func getImageType(from data: Data) -> String {
        let pngHeader = Data([0x89, 0x50, 0x4E, 0x47])
        return if data.prefix(4) == pngHeader { "png" } else { "jpeg" }
    }
}
