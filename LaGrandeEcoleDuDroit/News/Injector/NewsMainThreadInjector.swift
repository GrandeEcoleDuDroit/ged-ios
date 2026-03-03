import Swinject

class NewsMainThreadInjector: MainThreadInjector {
    let container: Container
    static var shared: MainThreadInjector = NewsMainThreadInjector()
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        // View models
        container.register(NewsViewModel.self) { resolver in
            NewsViewModel(
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                announcementRepository: NewsInjector.shared.resolve(AnnouncementRepository.self),
                deleteAnnouncementUseCase: NewsInjector.shared.resolve(DeleteAnnouncementUseCase.self),
                recreateAnnouncementUseCase: NewsInjector.shared.resolve(RecreateAnnouncementUseCase.self),
                refreshAnnouncementsUseCase: NewsInjector.shared.resolve(RefreshAnnouncementsUseCase.self),
                postRepository: NewsInjector.shared.resolve(PostRepository.self),
                deletePostUseCase: NewsInjector.shared.resolve(DeletePostUseCase.self)
            )
        }
        
        container.register(NewsNavigationViewModel.self) { resolver in
            NewsNavigationViewModel(
                routeRepository: CommonInjector.shared.resolve(RouteRepository.self)
            )
        }
        
        container.register(ReadAnnouncementViewModel.self) { (resolver, announcementId: Any) in
            let announcementId = announcementId as! String
            return ReadAnnouncementViewModel(
                announcementId: announcementId,
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                announcementRepository: NewsInjector.shared.resolve(AnnouncementRepository.self),
                deleteAnnouncementUseCase: NewsInjector.shared.resolve(DeleteAnnouncementUseCase.self)
            )
        }
        
        container.register(CreateAnnouncementViewModel.self) { resolver in
            CreateAnnouncementViewModel(
                createAnnouncementUseCase: NewsInjector.shared.resolve(CreateAnnouncementUseCase.self),
                generateIdUseCase: CommonInjector.shared.resolve(GenerateIdUseCase.self),
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
            )
        }
        
        container.register(EditAnnouncementViewModel.self) { (resolver, announcement: Any) in
            let announcement = announcement as! Announcement
            return EditAnnouncementViewModel(
                announcement: announcement,
                announcementRepository: NewsInjector.shared.resolve(AnnouncementRepository.self)
            )
        }
        
        container.register(AllAnnouncementsViewModel.self) { resolver in
            AllAnnouncementsViewModel(
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                announcementRepository: NewsInjector.shared.resolve(AnnouncementRepository.self),
                deleteAnnouncementUseCase: NewsInjector.shared.resolve(DeleteAnnouncementUseCase.self),
                recreateAnnouncementUseCase: NewsInjector.shared.resolve(RecreateAnnouncementUseCase.self),
                refreshAnnouncementsUseCase: NewsInjector.shared.resolve(RefreshAnnouncementsUseCase.self)
            )
        }
        
        container.register(CreatePostViewModel.self) { resolver in
            CreatePostViewModel(
                createPostUseCase: NewsInjector.shared.resolve(CreatePostUseCase.self),
                generateIdUseCase: CommonInjector.shared.resolve(GenerateIdUseCase.self)
            )
        }
    }
}
