import SwiftUI
import Combine

class NewsViewModel: ObservableObject {
    @Published private(set) var user: User? = nil
    @Published private(set) var announcements: [Announcement] = []
    @Published private(set) var announcementState: AnnouncementState = .idle

    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let getAnnouncementsUseCase: GetAnnouncementsUseCase
    private let deleteAnnouncementUseCase: DeleteAnnouncementUseCase
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        getCurrentUserUseCase: GetCurrentUserUseCase,
        getAnnouncementsUseCase: GetAnnouncementsUseCase,
        deleteAnnouncementUseCase: DeleteAnnouncementUseCase
    ) {
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.getAnnouncementsUseCase = getAnnouncementsUseCase
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
                self?.user = user
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
