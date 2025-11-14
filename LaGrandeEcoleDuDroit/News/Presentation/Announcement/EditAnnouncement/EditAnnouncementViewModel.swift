import Foundation

class EditAnnouncementViewModel: ViewModel {
    private let announcement: Announcement
    private let announcementRepository: AnnouncementRepository
    private let networkMonitor: NetworkMonitor

    @Published var uiState: EditAnnouncementUiState = EditAnnouncementUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    
    init(
        announcement: Announcement,
        announcementRepository: AnnouncementRepository,
        networkMonitor: NetworkMonitor
    ) {
        self.announcementRepository = announcementRepository
        self.announcement = announcement
        self.networkMonitor = networkMonitor
        initUiState()
    }
    
    private func initUiState() {
        uiState.title = announcement.title.toString()
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
        guard networkMonitor.isConnected else {
            return event = ErrorEvent(message: getString(.noInternetConectionError))
        }
        
        uiState.loading = true
        let title = uiState.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let content = uiState.content.trimmingCharacters(in: .whitespacesAndNewlines)
                                                         
        Task { @MainActor [weak self] in
            do {
                guard let announcement = self?.announcement.copy({
                    $0.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
                    $0.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
                }) else {
                    return
                }

                try await self?.announcementRepository.updateAnnouncement(announcement: announcement)
                self?.event = SuccessEvent()
                self?.uiState.loading = false
            } catch {
                self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
                self?.uiState.loading = false
            }
        }
    }
    
    private func validateInput() -> Bool {
        validateTitle(uiState.title) || validateContent(uiState.content)
    }
    
    private func validateTitle(_ title: String) -> Bool {
        title != announcement.title.toString() && !uiState.content.isBlank()
    }
    
    private func validateContent(_ content: String) -> Bool {
        content != announcement.content && !uiState.content.isBlank()
    }
    
    struct EditAnnouncementUiState {
        var title: String = ""
        var content: String = ""
        fileprivate(set) var loading: Bool = false
        fileprivate(set) var enableUpdate: Bool = false
    }
}
