import Foundation
import Combine

class CreateAnnouncementViewModel: ViewModel {
    private let userRepository: UserRepository
    private let generateIdUseCase: GenerateIdUseCase
    private let createAnnouncementUseCase: CreateAnnouncementUseCase
    
    @Published var uiState: CreateAnnouncementUiState = CreateAnnouncementUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private let currentUser: User?

    init(
        createAnnouncementUseCase: CreateAnnouncementUseCase,
        generateIdUseCase: GenerateIdUseCase,
        userRepository: UserRepository
    ) {
        self.createAnnouncementUseCase = createAnnouncementUseCase
        self.userRepository = userRepository
        self.generateIdUseCase = generateIdUseCase
        self.currentUser = userRepository.currentUser
    }
    
    func createAnnouncement() {
        guard let currentUser else {
            return event = ErrorEvent(message: stringResource(.currentUserNotFoundError))
        }
        
        let title: String? = !uiState.title.isBlank() ? uiState.title : nil
        
        let announcement = Announcement(
            id: generateIdUseCase.execute(),
            title: title,
            content: uiState.content.trim(),
            date: Date(),
            author: currentUser,
            state: .draft
        )
        
        Task {
            await createAnnouncementUseCase.execute(announcement: announcement)
        }
    }
    
    func onTitleChange(_ title: String) {
        if title.count <= 300 {
            uiState.title = title
            uiState.createEnabled = validateInput()
        } else {
            uiState.title = String(title.prefix(300))
        }
    }
    
    func onContentChange(_ content: String) {
        if content.count <= 2000 {
            uiState.content = content
            uiState.createEnabled = validateInput()
        } else {
            uiState.content = String(content.prefix(2000))
        }
    }
    
    private func validateInput() -> Bool {
        !uiState.content.isBlank()
    }
    
    struct CreateAnnouncementUiState {
        var title: String = ""
        var content: String = ""
        fileprivate(set) var createEnabled: Bool = false
    }
}
