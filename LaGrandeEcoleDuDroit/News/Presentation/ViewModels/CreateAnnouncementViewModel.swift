import Foundation

class CreateAnnouncementViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var content: String = ""
    @Published var announcementState: AnnouncementState = .idle
    
    private var currentUser: User? = nil
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let createAnnouncementUseCase: CreateAnnouncementUseCase
    
    init(
        getCurrentUserUseCase: GetCurrentUserUseCase,
        createAnnouncementUseCase: CreateAnnouncementUseCase
    ) {
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.createAnnouncementUseCase = createAnnouncementUseCase
        currentUser = getCurrentUserUseCase.execute()
    }

    func createAnnouncement() async {
        guard currentUser != nil else {
            announcementState = .error(message: getString(gedString: GedString.user_not_found))
            return
        }
      
        announcementState = .loading
        let announcement = Announcement(id: "", title: title, content: content, date: Date.now, author: currentUser!)
        do {
            try await createAnnouncementUseCase.execute(announcement: announcement)
            announcementState = .created
        } catch {
            announcementState = .error(message: getString(gedString: GedString.error_creating_announcement))
        }
    }
}
