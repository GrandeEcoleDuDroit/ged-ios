class RegisterUseCase {
    private let authenticationRepository: AuthenticationRepository
    private let userRepository: UserRepository
    private let whiteListRepository: WhiteListRepository
    
    init(
        authenticationRepository: AuthenticationRepository,
        userRepository: UserRepository,
        whiteListRepository: WhiteListRepository
    ) {
        self.authenticationRepository = authenticationRepository
        self.userRepository = userRepository
        self.whiteListRepository = whiteListRepository
    }
    
    func execute(
        email: String,
        password: String,
        firstName: String,
        lastName: String,
        schoolLevel: SchoolLevel
    ) async throws {
        guard try await whiteListRepository.isUserWhitelisted(email: email) else {
            throw NetworkError.forbidden
        }
        
        let userId = try await authenticationRepository.registerWithEmailAndPassword(email: email, password: password)
        let user = User(
            id: userId,
            firstName: firstName,
            lastName: lastName,
            email: email,
            schoolLevel: schoolLevel,
            isMember: false,
            profilePictureUrl: nil,
            isDeleted: false
        )
        
        try await userRepository.createUser(user: user)
        authenticationRepository.setAuthenticated(true)
    }
}
