import Foundation
import Combine

class CreateAnnouncementViewModel: ObservableObject {
    private let userRepository: UserRepository
    private let createAnnouncementUseCase: CreateAnnouncementUseCase
    
    @Published var uiState: CreateAnnouncementUiState = CreateAnnouncementUiState()
    @Published var event: SingleUiEvent? = nil
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
        guard let user = self.user else {
            return event = ErrorEvent(message: getString(.userNotFoundError))
        }
        
        let title: String? = if uiState.title.trimmingCharacters(in: .whitespacesAndNewlines).isBlank {
            nil
        } else {
            uiState.title
        }
        
        let announcement = Announcement(
            id: GenerateIdUseCase.stringId(),
            title: title,
            content: uiState.content.trimmingCharacters(in: .whitespacesAndNewlines),
            date: Date(),
            author: user,
            state: .draft
        )
        
        createAnnouncementUseCase.execute(announcement: announcement)
    }
    
    func onTitleChange(_ title: String) {
        uiState.title = title
        uiState.enableCreate = validateInput()
    }
    
    func onContentChange(_ content: String) {
        uiState.content = content
        uiState.enableCreate = validateInput()
    }
    
    private func validateInput() -> Bool {
        !uiState.content.isBlank
    }
    
    struct CreateAnnouncementUiState {
        var title: String = ""
        var content: String = ""
        var loading: Bool = false
        var enableCreate: Bool = false
    }
}
