class DependencyContainer {
    static let shared = DependencyContainer()
    
    private init() { }
    
    // ---------------------------------- Common ----------------------------------//
    
    // Repositories
    
    private let gedConfig: GedConfig = GedConfig()
    
    private lazy var userFirestoreApi: UserFirestoreApi = UserFirestoreApiImpl()
    
    private lazy var userOracleApi: UserOracleApi = UserOracleApiImpl()
    
    private lazy var userLocalDataSource: UserLocalDataSource = UserLocalDataSource()
    
    private lazy var userRemoteDataSource: UserRemoteDataSource = UserRemoteDataSource(userFirestoreApi: userFirestoreApi, userOracleApi: userOracleApi)
    
    private lazy var gedDatabaseContainer: GedDatabaseContainer = GedDatabaseContainer()
    
    private lazy var userRepository: UserRepository = UserRepositoryImpl(
        userLocalDataSource: userLocalDataSource,
        userRemoteDataSource: userRemoteDataSource
    )
    
    // Mocks
    
    lazy var mockUserRepository: UserRepository = MockUserRepository()
    
    // UseCases

    lazy var createUserUseCase: CreateUserUseCase = {
        CreateUserUseCase(userRepository: userRepository)
    }()
    
    lazy var getCurrentUserUseCase: GetCurrentUserUseCase = {
        GetCurrentUserUseCase(userRepository: userRepository)
    }()
    
    lazy var setCurrentUserUseCase: SetCurrentUserUseCase = {
        SetCurrentUserUseCase(userRepository: userRepository)
    }()
    
    lazy var getUserUseCase: GetUserUseCase = {
        GetUserUseCase(userRepository: userRepository)
    }()
    
    lazy var getUsersUseCase: GetUsersUseCase = {
        GetUsersUseCase(userRepository: userRepository)
    }()
    
    lazy var getFilteredUsersUseCase: GetFilteredUsersUseCase = {
        GetFilteredUsersUseCase(userRepository: userRepository)
    }()
    
    lazy var sendVerificationEmailUseCase: SendVerificationEmailUseCase = {
        SendVerificationEmailUseCase(authenticationRemoteRepository: authenticationRepository)
    }()
    
    lazy var isEmailVerifiedUseCase: IsEmailVerifiedUseCase = {
        IsEmailVerifiedUseCase(authenticationRemoteRepository: authenticationRepository)
    }()
    
    lazy var generateIdUseCase: GenerateIdUseCase = {
        GenerateIdUseCase()
    }()
    
    // ---------------------------------- Authentication ---------------------------------- //
    
    // Repositories
    
    private lazy var firebaseAuthApi: FirebaseAuthApi = FirebaseAuthApiImpl()
    private lazy var authenticationRepository: AuthenticationRepository = AuthenticationRepositoryImpl(firebaseAuthApi: firebaseAuthApi)
    
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
        IsAuthenticatedUseCase(authenticationRemoteRepository: authenticationRepository)
    }()
    
    lazy var loginUseCase: LoginUseCase = {
        LoginUseCase(authenticationRemoteRepository: authenticationRepository)
    }()
    
    lazy var logoutUseCase: LogoutUseCase = {
        LogoutUseCase(authenticationRemoteRepository: authenticationRepository)
    }()
    
    lazy var registerUseCase: RegisterUseCase = {
        RegisterUseCase(authenticationRemoteRepository: authenticationRepository)
    }()
    
    // Mocks
    
    lazy var mockAuthenticationRepository: AuthenticationRepository = MockAuthenticationRepository()
    
    lazy var mockAuthenticationViewModel: AuthenticationViewModel = {
        AuthenticationViewModel(
            loginUseCase: LoginUseCase(authenticationRemoteRepository: mockAuthenticationRepository),
            isEmailVerifiedUseCase: IsEmailVerifiedUseCase(authenticationRemoteRepository: mockAuthenticationRepository),
            isAuthenticatedUseCase: IsAuthenticatedUseCase(authenticationRemoteRepository: mockAuthenticationRepository),
            getUserUseCase: GetUserUseCase(userRepository: mockUserRepository),
            setCurrentUserUseCase: SetCurrentUserUseCase(userRepository: mockUserRepository)
        )
    }()
    
    lazy var mockRegistrationViewModel: RegistrationViewModel = {
        RegistrationViewModel(
            registerUseCase: RegisterUseCase(authenticationRemoteRepository: mockAuthenticationRepository),
            sendVerificationEmailUseCase: SendVerificationEmailUseCase(authenticationRemoteRepository: mockAuthenticationRepository),
            isEmailVerifiedUseCase: IsEmailVerifiedUseCase(authenticationRemoteRepository: mockAuthenticationRepository),
            createUserUseCase: CreateUserUseCase(userRepository: mockUserRepository)
        )
    }()
    
    // ---------------------------------- News ---------------------------------- //

    // Repositories
    
    private lazy var announcementApi: AnnouncementApi = AnnouncementApiImpl()
    
    private lazy var announcementRemoteDataSource: AnnouncementRemoteDataSource = AnnouncementRemoteDataSource(announcementApi: announcementApi)
    
    private lazy var announcementLocalDataSource: AnnouncementLocalDataSource = AnnouncementLocalDataSource(gedDatabaseContainer: gedDatabaseContainer)
    
    private lazy var announcementRepository: AnnouncementRepository = {
        AnnouncementRepositoryImpl(
            announcementLocalDataSource: announcementLocalDataSource,
            announcementRemoteDataSource: announcementRemoteDataSource
        )
    }()
    
    // ViewModels
    
    lazy var newsViewModel: NewsViewModel = {
        NewsViewModel(
            getCurrentUserUseCase: getCurrentUserUseCase,
            getAnnouncementsUseCase: getAnnouncementsUseCase,
            createAnnouncementUseCase: createAnnouncementUseCase,
            updateAnnouncementUseCase: updateAnnouncementUseCase,
            deleteAnnouncementUseCase: deleteAnnouncementUseCase,
            generateIdUseCase: generateIdUseCase
        )
    }()
    
    // UseCases
    
    lazy var getAnnouncementsUseCase: GetAnnouncementsUseCase = {
        GetAnnouncementsUseCase(announcementRepository: announcementRepository)
    }()
    
    lazy var createAnnouncementUseCase: CreateAnnouncementUseCase = {
        CreateAnnouncementUseCase(announcementRepository: announcementRepository)
    }()
    
    lazy var updateAnnouncementUseCase: UpdateAnnouncementUseCase = {
        UpdateAnnouncementUseCase(announcementRepository: announcementRepository)
    }()
    
    lazy var deleteAnnouncementUseCase: DeleteAnnouncementUseCase = {
        DeleteAnnouncementUseCase(announcementRepository: announcementRepository)
    }()
    
    // Mocks
    
    private lazy var mockAnnouncementRepository: AnnouncementRepository = MockAnnouncementRepository()
    
    lazy var mockNewsViewModel: NewsViewModel = {
        NewsViewModel(
            getCurrentUserUseCase: GetCurrentUserUseCase(userRepository: mockUserRepository),
            getAnnouncementsUseCase: GetAnnouncementsUseCase(announcementRepository: mockAnnouncementRepository),
            createAnnouncementUseCase: CreateAnnouncementUseCase(announcementRepository: mockAnnouncementRepository),
            updateAnnouncementUseCase: UpdateAnnouncementUseCase(announcementRepository: mockAnnouncementRepository),
            deleteAnnouncementUseCase: DeleteAnnouncementUseCase(announcementRepository: mockAnnouncementRepository),
            generateIdUseCase: GenerateIdUseCase()
        )
    }()
    
    // ---------------------------------- Message ---------------------------------- //

    // Repositories
    
    lazy var conversationApi: ConversationApi = ConversationApiImpl()
    
    lazy var messageApi: MessageApi = MessageApiImpl()
    
    lazy var conversationLocalDataSource: ConversationLocalDataSource = ConversationLocalDataSource(gedDatabaseContainer: gedDatabaseContainer)
    
    lazy var conversationRemoteDataSource: ConversationRemoteDataSource = ConversationRemoteDataSource(conversationApi: conversationApi)
    
    lazy var messageLocalDataSource: MessageLocalDataSource = MessageLocalDataSource(gedDatabaseContainer: gedDatabaseContainer)
    
    lazy var messageRemoteDataSource: MessageRemoteDataSource = MessageRemoteDataSource(messageApi: messageApi)
    
    lazy var conversationRepository: ConversationRepository = ConversationRepositoryImpl(
        conversationLocalDataSource: conversationLocalDataSource,
        conversationRemoteDataSource: conversationRemoteDataSource
    )
    
    lazy var messageRepository: MessageRepository = MessageRepositoryImpl(
        messageLocalDataSource: messageLocalDataSource,
        messageRemoteDataSource: messageRemoteDataSource
    )
    
    lazy var userConversationRepository: UserConversationRepository = UserConversationRepositoryImpl(
        userRepository: userRepository,
        conversationRepository: conversationRepository
    )
    
    // ViewModels
    
    lazy var conversationViewModel: ConversationViewModel = {
        ConversationViewModel(
            getConversationsUIUseCase: getConversationsUIUseCase,
            deleteConversationUseCase: deleteConversationUseCase
        )
    }()
    
    lazy var createConversationViewModel: CreateConversationViewModel = {
        CreateConversationViewModel(
            getUsersUseCase: getUsersUseCase,
            getCurrentUserUseCase: getCurrentUserUseCase,
            getFilteredUsersUseCase: getFilteredUsersUseCase,
            generateIdUseCase: generateIdUseCase
        )
    }()
    
    // UseCases
    
    lazy var createConversationUseCase: CreateConversationUseCase = {
        CreateConversationUseCase(userConversationRepository: userConversationRepository)
    }()
    
    lazy var getLastMessagesUseCase: GetLastMessagesUseCase = {
        GetLastMessagesUseCase(messageRepository: messageRepository)
    }()
    
    lazy var getMessagesUseCase: GetMessagesUseCase = {
        GetMessagesUseCase(messageRepository: messageRepository)
    }()
    
    lazy var getConversationsUseCase: GetConversationsUserUseCase = {
        GetConversationsUserUseCase(userConversationRepository: userConversationRepository)
    }()
    
    lazy var getConversationsUIUseCase: GetConversationsUIUseCase = {
        GetConversationsUIUseCase(
            getConversationsUserUseCase: getConversationsUseCase,
            getLastMessagesUseCase: getLastMessagesUseCase
        )
    }()
    
    lazy var sendMessageUseCase: SendMessageUseCase = {
        SendMessageUseCase(messageRepository: messageRepository)
    }()
    
    lazy var deleteConversationUseCase: DeleteConversationUseCase = {
        DeleteConversationUseCase(userConversationRepository: userConversationRepository)
    }()

    // Mocks
    
    lazy var mockUserConversationRepository: UserConversationRepository = MockUserConversationRepository()
    
    lazy var mockMessageRepository: MessageRepository = MockMessageRepository()
    
    lazy var mockConversationViewModel: ConversationViewModel = {
        ConversationViewModel(
            getConversationsUIUseCase: GetConversationsUIUseCase(
                getConversationsUserUseCase: GetConversationsUserUseCase(userConversationRepository: mockUserConversationRepository),
                getLastMessagesUseCase: GetLastMessagesUseCase(messageRepository: mockMessageRepository)
            ),
            deleteConversationUseCase: DeleteConversationUseCase(userConversationRepository: mockUserConversationRepository)
        )
    }()
    
    lazy var mockCreateConversationViewModel: CreateConversationViewModel = {
        CreateConversationViewModel(
            getUsersUseCase: GetUsersUseCase(userRepository: mockUserRepository),
            getCurrentUserUseCase: GetCurrentUserUseCase(userRepository: mockUserRepository),
            getFilteredUsersUseCase: GetFilteredUsersUseCase(userRepository: mockUserRepository),
            generateIdUseCase: GenerateIdUseCase()
        )
    }()
    
    lazy var mockChatViewModel: ChatViewModel = {
        ChatViewModel(
            getMessagesUseCase: GetMessagesUseCase(messageRepository: mockMessageRepository),
            getCurrentUserUseCase: GetCurrentUserUseCase(userRepository: mockUserRepository),
            generateIdUseCase: GenerateIdUseCase(),
            createConversationUseCase: CreateConversationUseCase(userConversationRepository: mockUserConversationRepository),
            sendMessageUseCase: SendMessageUseCase(messageRepository: mockMessageRepository),
            conversation: conversationUIFixture
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
    
    // Mocks
    lazy var mockProfileViewModel: ProfileViewModel = {
        ProfileViewModel(
            getCurrentUserUseCase: GetCurrentUserUseCase(userRepository: mockUserRepository),
            logoutUseCase: LogoutUseCase(authenticationRemoteRepository: mockAuthenticationRepository)
        )
    }()
}
