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
        if let fileExtension = imageData.imageExtension() {
            let fileName = UserUtils.ProfilePicture.generateFileName(userId: user.id) + "." + fileExtension
            let imagePath = UserUtils.ProfilePicture.folderName + "/" + fileName
            
            try await imageRepository.uploadImage(imageData: imageData, imagePath: imagePath)
            try await userRepository.updateProfilePictureFileName(userId: user.id, profilePictureFileName: fileName)
        } else {
            throw ImageError.invalidFormat
        }
    }
}
