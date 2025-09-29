import Swinject

protocol DependencyInjectionContainer {
    static var shared: DependencyInjectionContainer { get }
    
    func resolve<T>(_ type: T.Type) -> T
    
    func resolve<T>(_ type: T.Type, arguments: Any...) -> T?
}
