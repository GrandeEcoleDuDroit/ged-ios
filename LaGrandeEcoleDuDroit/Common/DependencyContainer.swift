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
    
    // Mocks
    
    private var mockUserRemoteRepository: UserRemoteRepository = MockUserRemoteRepository()
    private var mockUserLocalRepository: UserLocalRepository = MockUserLocalRepository()
    
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
    
    lazy var getUsersUseCase: GetUsersUseCase = {
        GetUsersUseCase(userRemoteRepository: userRemoteRepository)
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
    
    // Mocks
    
    private lazy var mockAuthenticationRemoteRepository: AuthenticationRemoteRepository = MockAuthenticationRemoteRepository()
    
    lazy var mockAuthenticationViewModel: AuthenticationViewModel = {
        AuthenticationViewModel(
            loginUseCase: LoginUseCase(authenticationRemoteRepository: mockAuthenticationRemoteRepository),
            isEmailVerifiedUseCase: IsEmailVerifiedUseCase(authenticationRemoteRepository: mockAuthenticationRemoteRepository),
            isAuthenticatedUseCase: IsAuthenticatedUseCase(authenticationRemoteRepository: mockAuthenticationRemoteRepository),
            getUserUseCase: GetUserUseCase(userRemoteRepository: mockUserRemoteRepository),
            setCurrentUserUseCase: SetCurrentUserUseCase(userLocalRepository: mockUserLocalRepository)
        )
    }()
    
    lazy var mockRegistrationViewModel: RegistrationViewModel = {
        RegistrationViewModel(
            registerUseCase: RegisterUseCase(authenticationRemoteRepository: mockAuthenticationRemoteRepository),
            sendVerificationEmailUseCase: SendVerificationEmailUseCase(authenticationRemoteRepository: mockAuthenticationRemoteRepository),
            isEmailVerifiedUseCase: IsEmailVerifiedUseCase(authenticationRemoteRepository: mockAuthenticationRemoteRepository),
            createUserUseCase: CreateUserUseCase(
                userRemoteRepository: mockUserRemoteRepository,
                userLocalRepository: mockUserLocalRepository
            )
        )
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
    
    // Mocks
    
    private lazy var mockAnnouncementLocalRepository: AnnouncementLocalRepository = MockAnnouncementLocalRepository()
    private lazy var mockAnnouncementRemoteRepository: AnnouncementRemoteRepository = MockAnnouncementRemoteRepository()
    
    lazy var mockNewsViewModel: NewsViewModel = {
        NewsViewModel(
            getCurrentUserUseCase: GetCurrentUserUseCase(userLocalRepository: mockUserLocalRepository),
            getAnnouncementsUseCase: GetAnnouncementsUseCase(announcementLocalRepository: mockAnnouncementLocalRepository),
            createAnnouncementUseCase: CreateAnnouncementUseCase(
                announcementLocalRepository: mockAnnouncementLocalRepository,
                announcementRemoteRepository: mockAnnouncementRemoteRepository
            ),
            updateAnnouncementUseCase: UpdateAnnouncementUseCase(
                announcementLocalRepository: mockAnnouncementLocalRepository,
                announcementRemoteRepository: mockAnnouncementRemoteRepository
            ),
            deleteAnnouncementUseCase: DeleteAnnouncementUseCase(
                announcementRemoteRepository: mockAnnouncementRemoteRepository,
                announcementLocalRepository: mockAnnouncementLocalRepository
            )
        )
    }()
    
    // ---------------------------------- Message ---------------------------------- //

    // Repositories
    
    lazy var conversationLocalRepository: ConversationLocalRepository = ConversationLocalRepositoryImpl(gedDatabaseContainer: gedDatabaseContainer)
    
    // ViewModels
    
    lazy var conversationViewModel: ConversationViewModel = {
        ConversationViewModel(getConversationsUseCase: getConversationsUseCase)
    }()
    
    lazy var createConversationViewModel: CreateConversationViewModel = {
        CreateConversationViewModel(getUsersUseCase: getUsersUseCase)
    }()
    
    // UseCases
    
    lazy var getConversationsUseCase: GetConversationsUseCase = {
        GetConversationsUseCase(conversationLocalRepository: conversationLocalRepository)
    }()
    
    // Mocks
    
    lazy var mockConversationLocalRepository: ConversationLocalRepository = MockConversationLocalRepository()
    
    lazy var mockConversationViewModel: ConversationViewModel = {
        ConversationViewModel(getConversationsUseCase: GetConversationsUseCase(conversationLocalRepository: mockConversationLocalRepository))
    }()
    
    lazy var mockCreateConversationViewModel: CreateConversationViewModel = {
        CreateConversationViewModel(getUsersUseCase: GetUsersUseCase(userRemoteRepository: mockUserRemoteRepository))
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
