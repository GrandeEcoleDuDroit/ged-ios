import Foundation
import Combine

private let tag = String(describing: NewsViewModel.self)

class NewsViewModel: ObservableObject {
    private let getAnnouncementsUseCase: GetAnnouncementsUseCase
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private var cancellables: Set<AnyCancellable> = []
    let currentUser: User?
    
    @Published private(set) var announcements: [Announcement] = []
    @Published private(set) var announcementState: AnnouncementState = .idle
    
    init(
        getCurrentUserUseCase: GetCurrentUserUseCase,
        getAnnouncementsUseCase: GetAnnouncementsUseCase
    ) {
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.getAnnouncementsUseCase = getAnnouncementsUseCase
        
        self.currentUser = getCurrentUserUseCase.execute()
        initAnnouncements()
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
