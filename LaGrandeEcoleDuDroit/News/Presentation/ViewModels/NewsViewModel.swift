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
    private let generateIdUseCase: GenerateIdUseCase
    private var cancellables: Set<AnyCancellable> = []
    private var newsTasks: [Task<Void, Never>] = []
    
    init(
        getCurrentUserUseCase: GetCurrentUserUseCase,
        getAnnouncementsUseCase: GetAnnouncementsUseCase,
        createAnnouncementUseCase: CreateAnnouncementUseCase,
        updateAnnouncementUseCase: UpdateAnnouncementUseCase,
        deleteAnnouncementUseCase: DeleteAnnouncementUseCase,
        generateIdUseCase: GenerateIdUseCase
    ) {
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.getAnnouncementsUseCase = getAnnouncementsUseCase
        self.createAnnouncementUseCase = createAnnouncementUseCase
        self.updateAnnouncementUseCase = updateAnnouncementUseCase
        self.deleteAnnouncementUseCase = deleteAnnouncementUseCase
        self.generateIdUseCase = generateIdUseCase
        
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
    
    func createAnnouncement(title: String?, content: String) {
        guard let currentUser = currentUser else {
            announcementState = .error(message: getString(.authUserNotFound))
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
        
        let task = Task {
            do {
                try await createAnnouncementUseCase.execute(announcement: announcement)
                updateAnnouncementState(to: .created)
            } catch {
                updateAnnouncementState(to: .error(message: getString(.errorCreatingAnnouncement)))
            }
        }
        
        newsTasks.append(task)
    }
    
    func updateAnnouncement(announcement: Announcement) {
        updateAnnouncementState(to: .loading)
        
        let task = Task {
            do {
                try await updateAnnouncementUseCase.execute(announcement: announcement)
                announcements = announcements.map { $0.id == announcement.id ? announcement : $0 }
                updateAnnouncementState(to: .updated)
            } catch {
                updateAnnouncementState(to: .error(message: error.localizedDescription))
                e(tag, error.localizedDescription)
            }
        }
        
        newsTasks.append(task)
    }
    
    func deleteAnnouncement(announcement: Announcement) {
        updateAnnouncementState(to: .loading)
        
        let task = Task {
            do {
                try await deleteAnnouncementUseCase.execute(announcement: announcement)
                updateAnnouncementState(to: .deleted)
            } catch {
                e(tag, error.localizedDescription)
                updateAnnouncementState(to: .error(message: error.localizedDescription))
            }
        }
        
        newsTasks.append(task)
    }
    
    func resetAnnouncementState() {
        announcementState = .idle
    }
    
    private func updateAnnouncementState(to state: AnnouncementState) {
        DispatchQueue.main.async { [weak self] in
            self?.announcementState = state
        }
    }
    
    deinit {
        newsTasks.forEach { $0.cancel() }
    }
}
