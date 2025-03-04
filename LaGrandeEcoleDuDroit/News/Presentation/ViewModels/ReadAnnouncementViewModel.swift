import Foundation
import Combine

class ReadAnnouncementViewModel: ObservableObject {
    private let updateAnnouncementUseCase: UpdateAnnouncementUseCase
    private let deleteAnnouncementUseCase: DeleteAnnouncementUseCase
    private let getCurrentUserUseCase: GetCurrentUserUseCase
    private let getAnnouncementUseCase: GetAnnouncementUseCase
    private var cancellables: Set<AnyCancellable> = []
    let currentUser: User?
    
    @Published private(set) var screenState: AnnouncementScreenState = .initial
    @Published var announcement: Announcement
    
    init(
        updateAnnouncementUseCase: UpdateAnnouncementUseCase,
        deleteAnnouncementUseCase: DeleteAnnouncementUseCase,
        getCurrentUserUseCase: GetCurrentUserUseCase,
        getAnnouncementUseCase: GetAnnouncementUseCase,
        announcement: Announcement
    ) {
        self.updateAnnouncementUseCase = updateAnnouncementUseCase
        self.deleteAnnouncementUseCase = deleteAnnouncementUseCase
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.getAnnouncementUseCase = getAnnouncementUseCase
        self.announcement = announcement
        self.currentUser = getCurrentUserUseCase.execute().value
        
        listenAnnouncement()
    }
    
    func deleteAnnouncement() {
        updateScreenState(.loading)
        
        Task {
            do {
                try await deleteAnnouncementUseCase.execute(announcementId: announcement.id, state: announcement.state)
                updateScreenState(.deleted)
            } catch RequestError.invalidResponse {
                updateScreenState(.error(message: getString(.internalServerError)))
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
    
    func resetAnnouncementState() {
        updateScreenState(.initial)
    }
    
    private func listenAnnouncement() {
        getAnnouncementUseCase.execute(announcementId: announcement.id)
            .receive(on: RunLoop.main)
            .sink { [weak self] announcement in
                self?.announcement = announcement
            }
            .store(in: &cancellables)
    }
    
    private func updateScreenState(_ state: AnnouncementScreenState) {
        if Thread.isMainThread {
            screenState = state
        } else {
            DispatchQueue.main.sync { [weak self] in
                self?.screenState = state
            }
        }
    }
}
