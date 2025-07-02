import Foundation

class EditAnnouncementViewModel: ObservableObject {
    private let announcement: Announcement
    private let announcementRepository: AnnouncementRepository

    @Published var uiState: EditAnnouncementUiState = EditAnnouncementUiState()
    @Published var event: SingleUiEvent? = nil
    
    init(
        announcement: Announcement,
        announcementRepository: AnnouncementRepository
    ) {
        self.announcementRepository = announcementRepository
        self.announcement = announcement
        initUiState()
    }
    
    private func initUiState() {
        uiState.title = announcement.title ?? ""
        uiState.content = announcement.content
    }
    
    func onTitleChange(_ title: String) {
        uiState.title = title
        uiState.enableUpdate = validateInput()
    }
    
    func onContentChange(_ content: String) {
        uiState.content = content
        uiState.enableUpdate = validateInput()
    }
    
    func updateAnnouncement() {
        uiState.loading = true
        Task {
            defer { uiState.loading = false }
            do {
                let updatedAnnouncement = announcement.with(
                    title: uiState.title.trimmingCharacters(in: .whitespacesAndNewlines),
                    content: uiState.content.trimmingCharacters(in: .whitespacesAndNewlines)
                )
                try await announcementRepository.updateAnnouncement(announcement: updatedAnnouncement)
                updateEvent(SuccessEvent())
            } catch {
                updateEvent(ErrorEvent(message: mapNetworkErrorMessage(error)))
            }
        }
    }
    
    private func validateInput() -> Bool {
        validateTitle(uiState.title) || validateContent(uiState.content)
    }
    
    private func validateTitle(_ title: String) -> Bool {
        let announcementTitle = announcement.title ?? ""
        return title != announcementTitle && !uiState.content.isBlank
    }
    
    private func validateContent(_ content: String) -> Bool {
        content != announcement.content && !uiState.content.isBlank
    }
    
    private func updateEvent(_ event: SingleUiEvent) {
        DispatchQueue.main.sync { [weak self] in
            self?.event = event
        }
    }
    
    struct EditAnnouncementUiState {
        var title: String = ""
        var content: String = ""
        var loading: Bool = false
        var enableUpdate: Bool = false
    }
}
