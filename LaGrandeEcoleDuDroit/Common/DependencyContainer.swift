class DependencyContainer {
    static let shared = DependencyContainer()
    
    private init() { }
    
    // ---------------------------------- Common ----------------------------------//
    
    // Repositories
    
    private let gedConfig: GedConfig = GedConfig()
    private lazy var userFirestoreApi: UserFirestoreApi = UserFirestoreApiImpl()
    private lazy var userOracleApi: UserOracleApi = UserOracleApiImpl()
    private lazy var userLocalRepository: UserLocalRepository = UserLocalRepositoryImpl()
    private lazy var userRemoteRepository: UserRemoteRepository = UserRemoteRepositoryImpl(userFirestoreApi: userFirestoreApi, userOracleApi: userOracleApi)
    private lazy var gedDatabaseContainer: GedDatabaseContainer = GedDatabaseContainer()
    
    // UseCases

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
    
    lazy var sendVerificationEmailUseCase: SendVerificationEmailUseCase = {
        SendVerificationEmailUseCase(authenticationRemoteRepository: authenticationRemoteRepository)
    }()
    
    lazy var isEmailVerifiedUseCase: IsEmailVerifiedUseCase = {
        IsEmailVerifiedUseCase(authenticationRemoteRepository: authenticationRemoteRepository)
    }()
    
    // ---------------------------------- Authentication ---------------------------------- //
    
    // Repositories
    
    private lazy var firebaseAuthApi: FirebaseAuthApi = FirebaseAuthApiImpl()
    private lazy var authenticationRemoteRepository: AuthenticationRemoteRepository = AuthenticationRemoteRepositoryImpl(firebaseAuthApi: firebaseAuthApi)
    
    // ViewModels
    
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
    
    // UseCases
    
    lazy var isAuthenticatedUseCase: IsAuthenticatedUseCase = {
        IsAuthenticatedUseCase(authenticationRemoteRepository: authenticationRemoteRepository)
    }()
    
    lazy var loginUseCase: LoginUseCase = {
        LoginUseCase(authenticationRemoteRepository: authenticationRemoteRepository)
    }()
    
    lazy var logoutUseCase: LogoutUseCase = {
        LogoutUseCase(authenticationRemoteRepository: authenticationRemoteRepository)
    }()
    
    lazy var registerUseCase: RegisterUseCase = {
        RegisterUseCase(authenticationRemoteRepository: authenticationRemoteRepository)
    }()
    
    // ---------------------------------- News ---------------------------------- //

    // Repositories
    
    private lazy var announcementApi: AnnouncementApi = AnnouncementApiImpl()
    private lazy var announcementRemoteRepository: AnnouncementRemoteRepository = AnnouncementRemoteRepositoryImpl(announcementApi: announcementApi)
    private lazy var announcementLocalRepository: AnnouncementLocalRepository = AnnouncementLocalRepositoryImpl(gedDatabaseContainer: gedDatabaseContainer)
    
    // ViewModels
    
    lazy var newsViewModel: NewsViewModel = {
        NewsViewModel(
            getCurrentUserUseCase: getCurrentUserUseCase,
            getAnnouncementsUseCase: getAnnouncementsUseCase,
            createAnnouncementUseCase: createAnnouncementUseCase,
            updateAnnouncementUseCase: updateAnnouncementUseCase,
            deleteAnnouncementUseCase: deleteAnnouncementUseCase
        )
    }()
    
    // UseCases
    
    lazy var getAnnouncementsUseCase: GetAnnouncementsUseCase = {
        GetAnnouncementsUseCase(announcementLocalRepository: announcementLocalRepository)
    }()
    
    lazy var createAnnouncementUseCase: CreateAnnouncementUseCase = {
        CreateAnnouncementUseCase(
            announcementLocalRepository: announcementLocalRepository,
            announcementRemoteRepository: announcementRemoteRepository
        )
    }()
    
    lazy var updateAnnouncementUseCase: UpdateAnnouncementUseCase = {
        UpdateAnnouncementUseCase(
            announcementLocalRepository: announcementLocalRepository,
            announcementRemoteRepository: announcementRemoteRepository
        )
    }()
    
    lazy var deleteAnnouncementUseCase: DeleteAnnouncementUseCase = {
        DeleteAnnouncementUseCase(
            announcementRemoteRepository: announcementRemoteRepository,
            announcementLocalRepository: announcementLocalRepository
        )
    }()
    
    // ---------------------------------- Profile ---------------------------------- //

    // ViewModels
    
    lazy var profileViewModel: ProfileViewModel = {
        ProfileViewModel(
            getCurrentUserUseCase: getCurrentUserUseCase,
            logoutUseCase: logoutUseCase
        )
    }()
    
}
