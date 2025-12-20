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
    
    func execute(user: User) async throws {
        guard let profilePictureUrl = user.profilePictureUrl else { return }
        
        try await userRepository.deleteProfilePictureFileName(user: user)
        
        if let fileName = UserUtils.ProfilePicture.getFileName(url: profilePictureUrl) {
            let imagePath = UserUtils.ProfilePicture.relativePath(fileName: fileName)
            try await imageRepository.deleteRemoteImage(imagePath: imagePath)
        }
    }
}
