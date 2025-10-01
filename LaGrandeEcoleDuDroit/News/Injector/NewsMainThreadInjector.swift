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
                resendAnnouncementUseCase: NewsInjector.shared.resolve(ResendAnnouncementUseCase.self),
                refreshAnnouncementsUseCase: NewsInjector.shared.resolve(RefreshAnnouncementsUseCase.self),
                networkMonitor: CommonInjector.shared.resolve(NetworkMonitor.self)
            )
        }
        
        container.register(ReadAnnouncementViewModel.self) { (resolver, announcementId: Any) in
            let announcementId = announcementId as! String
            return ReadAnnouncementViewModel(
                announcementId: announcementId,
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                announcementRepository: NewsInjector.shared.resolve(AnnouncementRepository.self),
                deleteAnnouncementUseCase: NewsInjector.shared.resolve(DeleteAnnouncementUseCase.self),
                networkMonitor: CommonInjector.shared.resolve(NetworkMonitor.self)
            )
        }
        
        container.register(CreateAnnouncementViewModel.self) { resolver in
            CreateAnnouncementViewModel(
                createAnnouncementUseCase: NewsInjector.shared.resolve(CreateAnnouncementUseCase.self),
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
    }
}
