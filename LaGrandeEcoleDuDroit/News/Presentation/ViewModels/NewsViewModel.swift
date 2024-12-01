import SwiftUI
import Combine

class NewsViewModel: ObservableObject {
    @Published private(set) var currentUser: User? = nil
    @Published var announcements: [Announcement] = []
    @Published private(set) var announcementState: AnnouncementState = .idle

    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let getAnnouncementsUseCase: GetAnnouncementsUseCase
    private let createAnnouncementUseCase: CreateAnnouncementUseCase
    private let updateAnnouncementUseCase: UpdateAnnouncementUseCase
    private let deleteAnnouncementUseCase: DeleteAnnouncementUseCase
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        getCurrentUserUseCase: GetCurrentUserUseCase,
        getAnnouncementsUseCase: GetAnnouncementsUseCase,
        createAnnouncementUseCase: CreateAnnouncementUseCase,
        updateAnnouncementUseCase: UpdateAnnouncementUseCase,
        deleteAnnouncementUseCase: DeleteAnnouncementUseCase
    ) {
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.getAnnouncementsUseCase = getAnnouncementsUseCase
        self.createAnnouncementUseCase = createAnnouncementUseCase
        self.updateAnnouncementUseCase = updateAnnouncementUseCase
        self.deleteAnnouncementUseCase = deleteAnnouncementUseCase
        
        initCurrentUser()
        initAnnouncements()
    }
    
    private func initCurrentUser() {
        getCurrentUserUseCase.executeWithPublisher()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching user: \(error)")
                }
            }, receiveValue: { [weak self] user in
                self?.currentUser = user
            })
            .store(in: &cancellables)
    }
    
    private func initAnnouncements() {
        getAnnouncementsUseCase.execute()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching announcements: \(error)")
                }
            }, receiveValue: { [weak self] announcements in
                self?.announcements = announcements.sorted(by: { $0.date > $1.date })
            })
            .store(in: &cancellables)
    }
    
    func createAnnouncement(title: String?, content: String) async {
        guard let currentUser = currentUser else {
            announcementState = .error(message: getString(gedString: GedString.user_not_found))
            return
        }
        
        let announcement = Announcement(
            id: UUID().uuidString,
            title: title,
            content: content,
            date: Date.now,
            author: currentUser
        )
      
        await updateAnnouncementState(to: .loading)
        do {
            try await createAnnouncementUseCase.execute(announcement: announcement)
            await updateAnnouncementState(to: .created)
        } catch {
            await updateAnnouncementState(to: .error(message: getString(gedString: GedString.error_creating_announcement)))
        }
    }
    
    func updateAnnouncement(id: String, title: String, content: String) async {
        guard let currentUser = currentUser else {
            announcementState = .error(message: getString(gedString: GedString.user_not_found))
            return
        }
        
        let announcement = Announcement(
            id: id,
            title: title,
            content: content,
            date: Date.now,
            author: currentUser
        )
        
        do {
            await updateAnnouncementState(to: .loading)
            try await updateAnnouncementUseCase.execute(announcement: announcement)
            announcements = announcements.map { $0.id == id ? announcement : $0 }
            await updateAnnouncementState(to: .updated)
        } catch {
            await updateAnnouncementState(to: .error(message: error.localizedDescription))
            print(error.localizedDescription)
        }
    }
    
    func deleteAnnouncement(announcement: Announcement) async {
        do {
            await updateAnnouncementState(to: .loading)
            try await deleteAnnouncementUseCase.execute(announcement: announcement)
            await updateAnnouncementState(to: .deleted)
        } catch {
            print(error.localizedDescription)
            await updateAnnouncementState(to: .error(message: error.localizedDescription))
        }
    }
    
    func resetAnnouncementState() {
        announcementState = .idle
    }
    
    private func updateAnnouncementState(to state: AnnouncementState) async {
        await MainActor.run {
            announcementState = state
        }
    }
}
