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
    
    func execute(user: User, imageData: Data) async throws {
        let fileType = getImageType(from: imageData)
        let fileName = getFileName(userId: user.id) + ".\(fileType)"
        
        try await imageRepository.uploadImage(imageData: imageData, fileName: fileName)
        try await userRepository.updateProfilePictureFileName(userId: user.id, profilePictureFileName: fileName)
    }
    
    func getImageType(from data: Data) -> String {
        let pngHeader = Data([0x89, 0x50, 0x4E, 0x47])
        return if data.prefix(4) == pngHeader { "png" } else { "jpeg" }
    }
    
    private func getFileName(userId: String) -> String {
        let currentTime = Date().toEpochMilli()
        return "\(userId)-profile-picture-\(currentTime)"
    }
}
