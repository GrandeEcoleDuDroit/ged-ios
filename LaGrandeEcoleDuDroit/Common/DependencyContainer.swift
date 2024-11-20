class DependencyContainer {
    static let shared = DependencyContainer()
    
    private init() { }
    
    // ---------------------------------- Repositories ----------------------------------//
    
    // Common
    private var firestoreConfig = FirestoreConfig()
    private lazy var userFirestoreApi: UserFirestoreApi = UserFirestoreApiImpl()
    private lazy var userOracleApi: UserOracleApi = UserOracleApiImpl()
    private lazy var userLocalRepository: UserLocalRepository = UserLocalRepositoryImpl()
    private lazy var userRemoteRepository: UserRemoteRepository = UserRemoteRepositoryImpl(userFirestoreApi: userFirestoreApi, userOracleApi: userOracleApi)
    private lazy var gedDatabaseContainer: GedDatabaseContainer = GedDatabaseContainer()
    
    // Authentication
    private var firebaseAuthConfig = FirebaseAuthConfig()
    private lazy var firebaseAuthApi: FirebaseAuthApi = FirebaseAuthApiImpl()
    private lazy var authenticationRemoteRepository: AuthenticationRemoteRepository = AuthenticationRemoteRepositoryImpl(firebaseAuthApi: firebaseAuthApi)
    
    // News
    private lazy var announcementApi: AnnouncementApi = AnnouncementApiImpl()
    private lazy var announcementRemoteRepository: AnnouncementRemoteRepository = AnnouncementRemoteRepositoryImpl(announcementApi: announcementApi)
    private lazy var announcementLocalRepository: AnnouncementLocalRepository = AnnouncementLocalRepositoryImpl(gedDatabaseContainer: gedDatabaseContainer)
    
    // ---------------------------------- ViewModels ---------------------------------- //
    
    // Authentication
    lazy var authenticationViewModel: AuthenticationViewModel = {
        AuthenticationViewModel(
            loginUseCase: loginUseCase,
            isEmailVerifiedUseCase: isEmailVerifiedUseCase,
            isAuthenticatedUseCase: isAuthenticatedUseCase,
            getUserUseCase: getUserUseCase,
            setCurrentUserUseCase: setCurrentUserUseCase
        )
    }()

    lazy var registrationViewModel: RegistrationViewModel = {
        RegistrationViewModel(
            registerUseCase: registerUseCase,
            sendVerificationEmailUseCase: sendVerificationEmailUseCase,
            isEmailVerifiedUseCase: isEmailVerifiedUseCase,
            createUserUseCase: createUserUseCase
        )
    }()
    
    // News
    lazy var newsViewModel: NewsViewModel = {
        NewsViewModel(
            getCurrentUserUseCase: getCurrentUserUseCase,
            getAnnouncementsUseCase: getAnnouncementsUseCase
        )
    }()
    
    lazy var createAnnouncementViewModel: CreateAnnouncementViewModel = {
        CreateAnnouncementViewModel(
            getCurrentUserUseCase: getCurrentUserUseCase,
            createAnnouncementUseCase: createAnnouncementUseCase
        )
    }()
    
    
    
    // ---------------------------------- UseCases ---------------------------------- //
    
    // Common
    lazy var createUserUseCase: CreateUserUseCase = {
        CreateUserUseCase(
            userRemoteRepository: userRemoteRepository,
            userLocalRepository: userLocalRepository
        )
    }()
    
    lazy var getCurrentUserUseCase: GetCurrentUserUseCase = {
        GetCurrentUserUseCase(userLocalRepository: userLocalRepository)
    }()
    
    lazy var setCurrentUserUseCase: SetCurrentUserUseCase = {
        SetCurrentUserUseCase(userLocalRepository: userLocalRepository)
    }()
    
    lazy var getUserUseCase: GetUserUseCase = {
        GetUserUseCase(userRemoteRepository: userRemoteRepository)
    }()
    
    // Authentication
    lazy var isAuthenticatedUseCase: IsAuthenticatedUseCase = {
        IsAuthenticatedUseCase(firebaseAuthApi: firebaseAuthApi)
    }()
    
    lazy var loginUseCase: LoginUseCase = {
        LoginUseCase(authenticationRemoteRepository: authenticationRemoteRepository)
    }()
    
    lazy var registerUseCase: RegisterUseCase = {
        RegisterUseCase(authenticationRemoteRepository: authenticationRemoteRepository)
    }()
    
    lazy var sendVerificationEmailUseCase: SendVerificationEmailUseCase = {
        SendVerificationEmailUseCase(authenticationRemoteRepository: authenticationRemoteRepository)
    }()
    
    lazy var isEmailVerifiedUseCase: IsEmailVerifiedUseCase = {
        IsEmailVerifiedUseCase(authenticationRemoteRepository: authenticationRemoteRepository)
    }()
    
    // News
    lazy var getAnnouncementsUseCase: GetAnnouncementsUseCase = {
        GetAnnouncementsUseCase(announcementLocalRepository: announcementLocalRepository)
    }()
    
    lazy var createAnnouncementUseCase: CreateAnnouncementUseCase = {
        CreateAnnouncementUseCase(
            announcementLocalRepository: announcementLocalRepository,
            announcementRemoteRepository: announcementRemoteRepository
        )
    }()
}
