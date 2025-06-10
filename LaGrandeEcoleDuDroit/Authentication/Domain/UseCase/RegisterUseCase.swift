class RegisterUseCase {
    private let authenticationRepository: AuthenticationRepository
    private let userRepository: UserRepository
    private let whiteListRepository: WhiteListRepository
    private let networkMonitor: NetworkMonitor
    
    init(
        authenticationRepository: AuthenticationRepository,
        userRepository: UserRepository,
        whiteListRepository: WhiteListRepository,
        networkMonitor: NetworkMonitor
    ) {
        self.authenticationRepository = authenticationRepository
        self.userRepository = userRepository
        self.whiteListRepository = whiteListRepository
        self.networkMonitor = networkMonitor
    }
    
    func execute(
        email: String,
        password: String,
        firstName: String,
        lastName: String,
        schoolLevel: SchoolLevel
    ) async throws {
        guard networkMonitor.isConnected else {
            throw NetworkError.noInternetConnection
        }
        
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
            profilePictureUrl: nil
        )
        try await userRepository.createUser(user: user)
        authenticationRepository.setAuthenticated(true)
    }
}
