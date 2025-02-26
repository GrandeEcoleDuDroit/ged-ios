import Foundation
import Combine

class CreateAnnouncementViewModel: ObservableObject {
    private let createAnnouncementUseCase: CreateAnnouncementUseCase
    private let generateIdUseCase: GenerateIdUseCase
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let currentUser: User?

    @Published var title: String?
    @Published var content: String = ""
    @Published private(set) var announcementState: AnnouncementState = .loading
    
    init(
        createAnnouncementUseCase: CreateAnnouncementUseCase,
        generateIdUseCase: GenerateIdUseCase,
        getCurrentUserUseCase: GetCurrentUserUseCase
    ) {
        self.createAnnouncementUseCase = createAnnouncementUseCase
        self.generateIdUseCase = generateIdUseCase
        self.getCurrentUserUseCase = getCurrentUserUseCase
        
        currentUser = getCurrentUserUseCase.execute().value
    }
    
    func createAnnouncement(title: String = "", content: String) {
        guard let currentUser = currentUser else {
            updateAnnouncementState(to: .error(message: getString(.authUserNotFound)))
            return
        }
        
        let announcement = Announcement(
            id: generateIdUseCase.execute(),
            title: title,
            content: content,
            date: Date.now,
            author: currentUser
        )
      
        updateAnnouncementState(to: .loading)
        
        Task {
            do {
                try await createAnnouncementUseCase.execute(announcement: announcement)
                updateAnnouncementState(to: .created)
            } catch {
                updateAnnouncementState(to: .error(message: getString(.errorCreatingAnnouncement)))
            }
        }
    }
    
    private func updateAnnouncementState(to state: AnnouncementState) {
        if Thread.isMainThread {
            announcementState = state
        } else {
            DispatchQueue.main.sync { [weak self] in
                self?.announcementState = state
            }
        }
    }
}
