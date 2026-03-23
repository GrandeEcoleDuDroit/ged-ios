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
            let path = UserUtils.ProfilePicture.getRelativePath(fileName: fileName)
            let fileData = FileData(path: path, data: imageData)
            try await userRepository.updateProfilePicture(user: user, fileData: fileData)
        } else {
            throw ImageError.invalidFormat
        }
    }
}
