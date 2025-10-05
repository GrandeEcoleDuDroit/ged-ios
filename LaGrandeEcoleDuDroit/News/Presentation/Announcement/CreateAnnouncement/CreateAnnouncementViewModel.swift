import Foundation
import Combine

class CreateAnnouncementViewModel: ViewModel {
    private let userRepository: UserRepository
    private let createAnnouncementUseCase: CreateAnnouncementUseCase
    
    @Published var uiState: CreateAnnouncementUiState = CreateAnnouncementUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private let user: User?

    init(
        createAnnouncementUseCase: CreateAnnouncementUseCase,
        userRepository: UserRepository
    ) {
        self.createAnnouncementUseCase = createAnnouncementUseCase
        self.userRepository = userRepository
        self.user = userRepository.currentUser
    }
    
    func createAnnouncement() {
        guard let user else {
            return event = ErrorEvent(message: getString(.userNotFoundError))
        }
        
        let title: String? = !uiState.title.isBlank ? uiState.title : nil
        
        let announcement = Announcement(
            id: GenerateIdUseCase.stringId(),
            title: title,
            content: uiState.content.trimmingCharacters(in: .whitespacesAndNewlines),
            date: Date(),
            author: user,
            state: .draft
        )
        
        Task {
            await createAnnouncementUseCase.execute(announcement: announcement)
        }
    }
    
    func onTitleChange(_ title: String) {
        if title.count <= 300 {
            uiState.title = title
            uiState.enableCreate = validateInput()
        } else {
            uiState.title = String(title.prefix(300))
        }
    }
    
    func onContentChange(_ content: String) {
        if content.count <= 2000 {
            uiState.content = content
            uiState.enableCreate = validateInput()
        } else {
            uiState.content = String(content.prefix(2000))
        }
    }
    
    private func validateInput() -> Bool {
        !uiState.content.isBlank
    }
    
    struct CreateAnnouncementUiState {
        var title: String = ""
        var content: String = ""
        fileprivate(set) var loading: Bool = false
        fileprivate(set) var enableCreate: Bool = false
    }
}
