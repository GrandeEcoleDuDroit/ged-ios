class DeleteAccountUseCase {
    private let userRepository: UserRepository
    private let authenticationRepository: AuthenticationRepository
    private let announcementRepository: AnnouncementRepository
    private let imageRepository: ImageRepository
    
    init(
        userRepository: UserRepository,
        authenticationRepository: AuthenticationRepository,
        announcementRepository: AnnouncementRepository,
        imageRepository: ImageRepository
    ) {
        self.userRepository = userRepository
        self.authenticationRepository = authenticationRepository
        self.announcementRepository = announcementRepository
        self.imageRepository = imageRepository
    }

    func execute(user: User, password: String) async throws {
        try await authenticationRepository.loginWithEmailAndPassword(email: user.email, password: password)
        try await announcementRepository.deleteAnnouncements(userId: user.id)
        try await deleteUser(user: user)
        try await authenticationRepository.deleteAuthUser()
    }
    
    private func deleteUser(user: User) async throws {
        let deletedUser = user.copy {
            $0.email = "\(user.id)@deleted.com"
            $0.profilePictureUrl = nil;
            $0.state = .deleted
        }
        
        try await userRepository.updateRemoteUser(user: deletedUser)
        if let profilePictureUrl = user.profilePictureUrl,
            let fileName = UrlUtils.extractFileNameFromUrl(url: profilePictureUrl) {
            try await imageRepository.deleteRemoteImage(fileName: fileName)
        }
        userRepository.deleteLocalUser()
    }
}
