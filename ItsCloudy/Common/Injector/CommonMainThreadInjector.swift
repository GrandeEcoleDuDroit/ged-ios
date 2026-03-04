import Swinject

class CommonMainThreadInjector: MainThreadInjector {
    let container: Container
    static var shared: MainThreadInjector = CommonMainThreadInjector()
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        // View Models
        container.register(UserViewModel.self) { (resolver, userId: Any) in
            let userId = userId as! String
            return UserViewModel(
                userId: userId,
                userRepository: CommonInjector.shared.resolve(UserRepository.self),
                blockedUserRepository: CommonInjector.shared.resolve(BlockedUserRepository.self)
            )
        }
    }
}
