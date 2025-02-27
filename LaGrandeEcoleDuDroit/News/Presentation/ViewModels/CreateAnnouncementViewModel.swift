import Foundation
import Combine

class CreateAnnouncementViewModel: ObservableObject {
    private let createAnnouncementUseCase: CreateAnnouncementUseCase
    private let generateIdUseCase: GenerateIdUseCase
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let currentUser: User?

    @Published var title: String?
    @Published var content: String = ""
    @Published private(set) var announcementState: AnnouncementState = .sending
    
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
    
    func createAnnouncement(title: String = "", content: String) throws {
        guard let currentUser = currentUser else {
            throw UserError.currentUserNotFound
        }
        
        let announcement = Announcement(
            id: generateIdUseCase.execute(),
            title: title,
            content: content,
            date: Date.now,
            author: currentUser,
            state: .sending
        )
        
        Task {
            await createAnnouncementUseCase.execute(announcement: announcement)
        }
    }
}
