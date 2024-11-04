import Combine

protocol UserLocalRepository {
    var currentUser: AnyPublisher<User?, Never> { get }
        
    func setCurrentUser(user: User)
    
    func removeCurrentUser()
}
