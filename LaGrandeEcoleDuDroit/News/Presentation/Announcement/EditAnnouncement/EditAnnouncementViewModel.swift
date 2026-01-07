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
        uiState.title = announcement.title.orEmpty()
        uiState.content = announcement.content
    }
    
    func onTitleChange(_ title: String) {
        uiState.title = title
        uiState.updateEnabled = validateInput()
    }
    
    func onContentChange(_ content: String) {
        uiState.content = content
        uiState.updateEnabled = validateInput()
    }
    
    func updateAnnouncement() {
        let (title, content) = (uiState.title.trim(), uiState.content.trim())
        let announcementToUpdate = announcement.copy {
            $0.title = title
            $0.content = content
        }
        
        performUiBlockingRequest(
            block: { [weak self] in
                try await self?.announcementRepository.updateAnnouncement(announcement: announcementToUpdate)
                self?.event = SuccessEvent()
            },
            onLoading: { [weak self] in
                self?.uiState.loading = true
            },
            onError: { [weak self] in
                self?.event = ErrorEvent(message: mapNetworkErrorMessage($0))
            },
            onFinally: { [weak self] in
                self?.uiState.loading = false
            }
        )
    }
    
    private func validateInput() -> Bool {
        validateTitle(uiState.title) || validateContent(uiState.content)
    }
    
    private func validateTitle(_ title: String) -> Bool {
        title != announcement.title.orEmpty() && !uiState.content.isBlank()
    }
    
    private func validateContent(_ content: String) -> Bool {
        content != announcement.content && !uiState.content.isBlank()
    }
    
    struct EditAnnouncementUiState {
        var title: String = ""
        var content: String = ""
        fileprivate(set) var loading: Bool = false
        fileprivate(set) var updateEnabled: Bool = false
    }    
}
