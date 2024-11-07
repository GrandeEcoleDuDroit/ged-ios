class DependencyContainer {
    static let shared = DependencyContainer()
    
    private init() { }
    
    // ---------------------------------- Repositories ----------------------------------//
    
    // Common
    private lazy var firestoreApi: FirestoreApi = FirestoreApiImpl()
    private lazy var userLocalRepository: UserLocalRepository = UserLocalRepositoryImpl()
    private lazy var userRemoteRepository: UserRemoteRepository = UserRemoteRepositoryImpl(firestoreApi: firestoreApi)
    
    // Authentication
    private lazy var firebaseAuthApi: FirebaseAuthApi = FirebaseAuthApiImpl()
    private lazy var authenticationRemoteRepository: AuthenticationRemoteRepository = AuthenticationRemoteRepositoryImpl(firebaseAuthApi: firebaseAuthApi)
    
    // News
    private lazy var announcementLocalRepository: AnnouncementLocalRepository = AnnouncementLocalRepositoryImpl()
    
    // ---------------------------------- ViewModels ---------------------------------- //
    
    // Authentication
    lazy var authenticationViewModel: AuthenticationViewModel = {
        return AuthenticationViewModel(
            loginUseCase: loginUseCase,
            isEmailVerifiedUseCase: isEmailVerifiedUseCase,
            isAuthenticatedUseCase: isAuthenticatedUseCase,
            getUserUseCase: getUserUseCase,
            setCurrentUserUseCase: setCurrentUserUseCase
        )
    }()

    lazy var registrationViewModel: RegistrationViewModel = {
        return RegistrationViewModel(
            registerUseCase: registerUseCase,
            sendVerificationEmailUseCase: sendVerificationEmailUseCase,
            isEmailVerifiedUseCase: isEmailVerifiedUseCase,
            createUserUseCase: createUserUseCase
        )
    }()
    
    // News
    lazy var newsViewModel: NewsViewModel = {
        return NewsViewModel(
            getCurrentUserUseCase: getCurrentUserUseCase,
            getAnnouncementsUseCase: getAnnouncementsUseCase
        )
    }()
    
    
    
    // ---------------------------------- UseCases ---------------------------------- //
    
    // Common
    lazy var createUserUseCase: CreateUserUseCase = {
        return CreateUserUseCase(
            userRemoteRepository: userRemoteRepository,
            userLocalRepository: userLocalRepository
        )
    }()
    
    lazy var getCurrentUserUseCase: GetCurrentUserUseCase = {
        return GetCurrentUserUseCase(userLocalRepository: userLocalRepository)
    }()
    
    lazy var setCurrentUserUseCase: SetCurrentUserUseCase = {
        return SetCurrentUserUseCase(userLocalRepository: userLocalRepository)
    }()
    
    lazy var getUserUseCase: GetUserUseCase = {
        return GetUserUseCase(userRemoteRepository: userRemoteRepository)
    }()
    
    // Authentication
    lazy var isAuthenticatedUseCase: IsAuthenticatedUseCase = {
        return IsAuthenticatedUseCase(firebaseAuthApi: firebaseAuthApi)
    }()
    
    lazy var loginUseCase: LoginUseCase = {
        return LoginUseCase(authenticationRemoteRepository: authenticationRemoteRepository)
    }()
    
    lazy var registerUseCase: RegisterUseCase = {
        return RegisterUseCase(authenticationRemoteRepository: authenticationRemoteRepository)
    }()
    
    lazy var sendVerificationEmailUseCase: SendVerificationEmailUseCase = {
        return SendVerificationEmailUseCase(authenticationRemoteRepository: authenticationRemoteRepository)
    }()
    
    lazy var isEmailVerifiedUseCase: IsEmailVerifiedUseCase = {
        return IsEmailVerifiedUseCase(authenticationRemoteRepository: authenticationRemoteRepository)
    }()
    
    // News
    lazy var getAnnouncementsUseCase: GetAnnouncementsUseCase = {
        return GetAnnouncementsUseCase(announcementLocalRepository: announcementLocalRepository)
    }()
}
