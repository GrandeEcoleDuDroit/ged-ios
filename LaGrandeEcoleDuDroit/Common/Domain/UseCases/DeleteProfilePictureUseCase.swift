class DeleteProfilePictureUseCase {
    private let userRepository: UserRepository
    private let imageRepository: ImageRepository
    
    init(
        userRepository: UserRepository,
        imageRepository: ImageRepository
    ) {
        self.userRepository = userRepository
        self.imageRepository = imageRepository
    }
    
    func execute(userId: String, profilePictureUrl: String) async throws {
        try await userRepository.deleteProfilePictureFileName(userId: userId)
        if let fileName = UrlUtils.getFileNameFromUrl(url: profilePictureUrl) {
            try await imageRepository.deleteImage(fileName: fileName)
        }
    }
}
