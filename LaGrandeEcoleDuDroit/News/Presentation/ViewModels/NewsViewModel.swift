import SwiftUI
import Combine

class NewsViewModel: ObservableObject {
    @Published var user: User? = nil
    @Published var announcements: [Announcement] = []
    
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let getAnnouncementsUseCase: GetAnnouncementsUseCase
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        getCurrentUserUseCase: GetCurrentUserUseCase,
        getAnnouncementsUseCase: GetAnnouncementsUseCase
    ) {
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.getAnnouncementsUseCase = getAnnouncementsUseCase
        
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
                self?.announcements = announcements
            })
            .store(in: &cancellables)
    }
}
