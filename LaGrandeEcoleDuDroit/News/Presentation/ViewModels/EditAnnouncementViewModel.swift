import Foundation

class EditAnnouncementViewModel: ObservableObject {
    private let updateAnnouncementUseCase: UpdateAnnouncementUseCase
    @Published var announcement: Announcement
    @Published private(set) var screenState: AnnouncementScreenState = .initial
    
    init(
        updateAnnouncementUseCase: UpdateAnnouncementUseCase,
        announcement: Announcement
    ) {
        self.updateAnnouncementUseCase = updateAnnouncementUseCase
        self.announcement = announcement
    }
    
    func updateAnnouncement() {
        updateScreenState(.loading)
        
        Task {
            do {
                try await updateAnnouncementUseCase.execute(announcement: announcement)
                updateScreenState(.updated)
            } catch let error as URLError {
                switch error.code {
                    case .notConnectedToInternet:
                        updateScreenState(.error(message: getString(.notConnectedToInternetError)))
                    case .timedOut:
                        updateScreenState(.error(message: getString(.timedOutError)))
                    case .networkConnectionLost:
                        updateScreenState(.error(message: getString(.networkConnectionLostError)))
                    case .cannotFindHost:
                        updateScreenState(.error(message: getString(.cannotFindHostError)))
                    default:
                        updateScreenState(.error(message: getString(.unknownNetworkError)))
                }
            } catch {
                updateScreenState(.error(message: getString(.unknownError)))
            }
        }
    }
    
    func updateScreenState(_ state: AnnouncementScreenState) {
        if Thread.isMainThread {
            screenState = state
        } else {
            DispatchQueue.main.sync { [weak self] in
                self?.screenState = state
            }
        }
    }
}
