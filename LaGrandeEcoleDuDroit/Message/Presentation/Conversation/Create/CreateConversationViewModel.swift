import Combine
import SwiftUI

class CreateConversationViewModel: ObservableObject {
    private let userRepository: UserRepository
    private let getLocalConversationUseCase: GetConversationUseCase
    private let loadImageUseCase: LoadImageUseCase

    private let tag = String(describing: CreateConversationViewModel.self)
    private var defaultUsers: [String: User] = [:]
    private var cancellables = Set<AnyCancellable>()
    @Published var uiState: CreateConversationUiState =
        CreateConversationUiState()
    @Published var event: SingleUiEvent? = nil

    init(
        userRepository: UserRepository,
        getLocalConversationUseCase: GetConversationUseCase,
        loadImageUseCase: LoadImageUseCase
    ) {
        self.userRepository = userRepository
        self.getLocalConversationUseCase = getLocalConversationUseCase
        self.loadImageUseCase = loadImageUseCase
        
        fetchUsers()
    }

    func onQueryChange(_ query: String) {
        uiState.query = query
        if query.isBlank {
            uiState.users = defaultUsers
        } else {
            uiState.users = defaultUsers.filter { users in
                users.value.fullName
                    .lowercased()
                    .contains(query.lowercased())
            }
        }
    }

    func getConversation(interlocutor: User) async -> Conversation? {
        do {
            return try await getLocalConversationUseCase.execute(
                interlocutor: interlocutor
            )
        } catch {
            updateEvent(ErrorEvent(message: mapNetworkErrorMessage(error)))
            return nil
        }
    }

    private func fetchUsers() {
        guard let user = userRepository.currentUser else {
            uiState.loading = false
            updateEvent(ErrorEvent(message: getString(.userNotFound)))
            return
        }

        uiState.loading = true

        Task {
            let users = await userRepository.getUsers()
                .filter { $0.id != user.id }
                .reduce(into: [String: User]()) { result, initial in
                    result[initial.id] = initial
                }
            
            DispatchQueue.main.sync { [weak self] in
                self?.uiState.loading = false
                self?.uiState.users = users
                self?.defaultUsers = users
            }
            
            loadUserImages(users: users)
        }
    }

    private func loadUserImages(users: [String: User]) {
        Task {
            await withTaskGroup { group in
                users.forEach { key, user in
                    group.addTask { [weak self] in
                        guard let profilePictureUrl = user.profilePictureUrl else {
                            return
                        }

                        DispatchQueue.main.sync { [weak self] in
                            self?.defaultUsers[key] = user.with(imagePhase: .loading)
                            if self?.uiState.users.contains(where: { $0.key == key }) == true {
                                self?.uiState.users[key] = user.with(imagePhase: .loading)
                            }
                        }

                        let imagePhase = await self?.loadImageUseCase.execute(
                            url: profilePictureUrl
                        ) ?? .empty

                        DispatchQueue.main.sync { [weak self] in
                            self?.defaultUsers[key] = user.with(imagePhase: imagePhase)
                            if self?.uiState.users.contains(where: { $0.key == key }) == true {
                                self?.uiState.users[key] = user.with(imagePhase: imagePhase)
                            }
                        }
                    }
                }

                await group.waitForAll()
            }
        }
    }

    private func updateEvent(_ event: SingleUiEvent) {
        DispatchQueue.main.sync { [weak self] in
            self?.event = event
        }
    }

    struct CreateConversationUiState: Withable {
        var users: [String: User] = [:]
        var loading: Bool = true
        var query: String = ""
    }
}
