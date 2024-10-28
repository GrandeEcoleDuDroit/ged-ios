import Combine

protocol AuthenticationRemoteRepository {
    func register(email: String, password: String) -> AnyPublisher<Void, Error>
}
