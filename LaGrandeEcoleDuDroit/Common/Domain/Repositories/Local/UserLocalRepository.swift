import Combine

protocol UserLocalRepository {
    var currentUserPublisher: AnyPublisher<User?, Never> { get }
    var currentUser: User? { get }
        
    func setCurrentUser(user: User)
    
    func removeCurrentUser()
}
