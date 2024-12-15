import Foundation
import Combine

class NewsViewModel: ObservableObject {
    private let tag = String(describing: NewsViewModel.self)
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
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.updateAnnouncementState(to: .error(message: error.localizedDescription))
                }
            }, receiveValue: { [weak self] user in
                self?.currentUser = user
            })
            .store(in: &cancellables)
    }
    
    private func initAnnouncements() {
        getAnnouncementsUseCase.execute()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.updateAnnouncementState(to: .error(message: error.localizedDescription))
                }
            }, receiveValue: { [weak self] announcements in
                self?.announcements = announcements.sorted(by: { $0.date > $1.date })
            })
            .store(in: &cancellables)
    }
    
    func createAnnouncement(title: String?, content: String) async {
        guard let currentUser = currentUser else {
            announcementState = .error(message: getString(gedString: GedString.auth_user_not_found))
            return
        }
        
        let announcement = Announcement(
            id: UUID().uuidString,
            title: title,
            content: content,
            date: Date.now,
            author: currentUser
        )
      
        updateAnnouncementState(to: .loading)
        do {
            try await createAnnouncementUseCase.execute(announcement: announcement)
            updateAnnouncementState(to: .created)
        } catch {
            updateAnnouncementState(to: .error(message: getString(gedString: GedString.error_creating_announcement)))
        }
    }
    
    func updateAnnouncement(id: String, title: String, content: String) async {
        guard let currentUser = currentUser else {
            announcementState = .error(message: getString(gedString: GedString.auth_user_not_found))
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
            updateAnnouncementState(to: .loading)
            try await updateAnnouncementUseCase.execute(announcement: announcement)
            announcements = announcements.map { $0.id == id ? announcement : $0 }
            updateAnnouncementState(to: .updated)
        } catch {
            updateAnnouncementState(to: .error(message: error.localizedDescription))
            e(tag, error.localizedDescription)
        }
    }
    
    func deleteAnnouncement(announcement: Announcement) async {
        do {
            updateAnnouncementState(to: .loading)
            try await deleteAnnouncementUseCase.execute(announcement: announcement)
            updateAnnouncementState(to: .deleted)
        } catch {
            e(tag, error.localizedDescription)
            updateAnnouncementState(to: .error(message: error.localizedDescription))
        }
    }
    
    func resetAnnouncementState() {
        announcementState = .idle
    }
    
    private func updateAnnouncementState(to state: AnnouncementState) {
        DispatchQueue.main.async { [weak self] in
            self?.announcementState = state
        }
    }
}
