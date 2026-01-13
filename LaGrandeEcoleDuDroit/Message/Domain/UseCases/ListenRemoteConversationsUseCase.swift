import Combine
import Foundation

private let tag = String(describing: ListenRemoteConversationsUseCase.self)

class ListenRemoteConversationsUseCase {
    private let userRepository: UserRepository
    private let conversationRepository: ConversationRepository
    private let listenRemoteMessagesUseCase: ListenRemoteMessagesUseCase
    
    private let fetchedInterlocutorActor: FetchedInterlocutorActor = FetchedInterlocutorActor()
    private var cancellables = Set<AnyCancellable>()

    init(
        userRepository: UserRepository,
        conversationRepository: ConversationRepository,
        listenRemoteMessagesUseCase: ListenRemoteMessagesUseCase
    ) {
        self.userRepository = userRepository
        self.conversationRepository = conversationRepository
        self.listenRemoteMessagesUseCase = listenRemoteMessagesUseCase
    }
    
    func start() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        userRepository.user
            .compactMap { [weak self] user in
                self?.listenConversations(user: user)
            }
            .switchToLatest()
            .receive(on: DispatchQueue.global(qos: .background))
            .sink { [weak self] conversation in
                Task { try? await self?.conversationRepository.upsertLocalConversation(conversation: conversation) }
                self?.listenRemoteMessagesUseCase.start(conversation: conversation)
            }.store(in: &cancellables)
                
    }
    
    func stop() {
        conversationRepository.stopListenConversations()
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        Task { await fetchedInterlocutorActor.removeAll() }
    }
    
    private func listenConversations(user: User) -> AnyPublisher<Conversation, Never> {
        conversationRepository
            .getRemoteConversationsPublisher(user: user)
            .flatMap { [weak self] remoteConversation in
                self?.getInterlocutorPublisher(remoteConversation: remoteConversation, currentUser: user)
                    .map { interlocutor in
                        remoteConversation.toConversation(userId: user.id, interlocutor: interlocutor)
                    }
                    .eraseToAnyPublisher()
                ?? Empty<Conversation, Never>().eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func getInterlocutorPublisher(remoteConversation: RemoteConversation, currentUser: User) -> AnyPublisher<User, Never> {
        guard let interlocutorId = remoteConversation.participants.first(where: { $0 != currentUser.id }) else {
            return Empty().eraseToAnyPublisher()
        }
        
        return Future<User?, Never> { [weak self] promise in
            Task {
                if let interlocutor = await self?.fetchedInterlocutorActor.get(interlocutorId: interlocutorId) {
                    promise(.success(interlocutor))
                } else {
                    promise(.success(nil))
                }
            }
        }
        .flatMap { [weak self] interlocutor -> AnyPublisher<User, Never> in
            if let interlocutor {
                Just(interlocutor).eraseToAnyPublisher()
            } else {
                self?.userRepository.getUserPublisher(userId: interlocutorId)
                    .catch { _ in Empty() }
                    .compactMap { $0 }
                    .map { interlocutor in
                        Task { await self?.fetchedInterlocutorActor.set(interlocutor: interlocutor) }
                        return interlocutor
                    }
                    .eraseToAnyPublisher()
                ?? Empty().eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
}

private actor FetchedInterlocutorActor {
    private var interlocutors: [String: User] = [:]
    
    func get(interlocutorId: String) -> User? {
        interlocutors[interlocutorId]
    }
    
    func set(interlocutor: User) {
        interlocutors[interlocutor.id] = interlocutor
    }
    
    func removeAll() {
        interlocutors.removeAll()
    }
}
