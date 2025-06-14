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
        if let fileName = profilePictureUrl.split(separator: "/").last {
            try await imageRepository.deleteImage(fileName: String(fileName))
        }
    }
}
