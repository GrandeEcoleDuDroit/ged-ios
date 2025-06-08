import Swinject

class ProfileInjection: DependencyInjectionContainer {
    static var shared: DependencyInjectionContainer = ProfileInjection()
    private let container: Container
    
    private init() {
        container = Container()
        registerDependencies()
    }
    
    private func registerDependencies() {
        container.register(ProfileViewModel.self) { resolver in
            ProfileViewModel(
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
                authenticationRepository: AuthenticationInjection.shared.resolve(AuthenticationRepository.self)
            )
        }
        
        container.register(AccountViewModel.self) { resolver in
            AccountViewModel(
                userRepository: CommonInjection.shared.resolve(UserRepository.self),
                updateProfilePictureUseCase: CommonInjection.shared.resolve(UpdateProfilePictureUseCase.self)
            )
        }
    }
    
    func resolve<T>(_ type: T.Type) -> T {
        guard let resolved = container.resolve(T.self) else {
            fatalError("Failed to resolve \(T.self)")
        }
        return resolved
    }
    
    func resolve<T>(_ type: T.Type, arguments: Any...) -> T? {
        switch arguments.count {
            case 1:
                return container.resolve(T.self, argument: arguments[0])
            case 2:
                return container.resolve(T.self, arguments: arguments[0], arguments[1])
            case 3:
                return container.resolve(T.self, arguments: arguments[0], arguments[1], arguments[2])
            case 4:
                return container.resolve(T.self, arguments: arguments[0], arguments[1], arguments[2], arguments[3])
            case 5:
                return container.resolve(T.self, arguments: arguments[0], arguments[1], arguments[2], arguments[3], arguments[4])
            case 6:
                return container.resolve(T.self, arguments: arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5])
            case 7:
                return container.resolve(T.self, arguments: arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6])
            case 8:
                return container.resolve(T.self, arguments: arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6], arguments[7])
            case 9:
                return container.resolve(T.self, arguments: arguments[0], arguments[1], arguments[2], arguments[3], arguments[4], arguments[5], arguments[6], arguments[7], arguments[8])
            default:
                return nil
        }
    }
    
    func resolveWithMock() -> Container {
        let mockContainer = Container()
        let commonMockContainer = CommonInjection.shared.resolveWithMock()
        let authenticationMockContainer = AuthenticationInjection.shared.resolveWithMock()
        
        mockContainer.register(ProfileViewModel.self) { resolver in
            ProfileViewModel(
                userRepository: commonMockContainer.resolve(UserRepository.self)!,
                authenticationRepository: authenticationMockContainer.resolve(AuthenticationRepository.self)!
            )
        }
        
        mockContainer.register(AccountViewModel.self) { resolver in
            AccountViewModel(
                userRepository: commonMockContainer.resolve(UserRepository.self)!,
                updateProfilePictureUseCase: commonMockContainer.resolve(UpdateProfilePictureUseCase.self)!
            )
        }
        
        return mockContainer
    }
}
