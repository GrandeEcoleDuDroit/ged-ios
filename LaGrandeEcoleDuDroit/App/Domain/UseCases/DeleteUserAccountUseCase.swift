
class DeleteUserAccountUseCase {
    private let userRepository: UserRepository
    private let authenticationRepository: AuthenticationRepository
    private let announcementRepository: AnnouncementRepository
    
    init(
        userRepository: UserRepository,
        authenticationRepository: AuthenticationRepository,
        announcementRepository: AnnouncementRepository
    ) {
        self.userRepository = userRepository
        self.authenticationRepository = authenticationRepository
        self.announcementRepository = announcementRepository
    }

    func execute(email: String, password: String) async throws {
        guard let userId = userRepository.currentUser?.id else {
            throw UserError.currentUserNotFound
        }
        try await authenticationRepository.loginWithEmailAndPassword(email: email, password: password)
        try await announcementRepository.deleteAnnouncements(userId: userId)
        try await userRepository.deleteCurrentUser()
        try await authenticationRepository.deleteAuthUser()
    }
}
