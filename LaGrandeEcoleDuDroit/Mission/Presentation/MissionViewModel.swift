import Combine
import Foundation

class MissionViewModel: ViewModel {
    private let missionRepository: MissionRepository
    private let userRepository: UserRepository
    private let refreshMissionsUseCase: RefreshMissionsUseCase
    private let deleteMissionUseCase: DeleteMissionUseCase
    private let networkMonitor: NetworkMonitor
    
    @Published private(set) var uiState = MissionUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private var cancellables: Set<AnyCancellable> = []

    init(
        missionRepository: MissionRepository,
        userRepository: UserRepository,
        refreshMissionsUseCase: RefreshMissionsUseCase,
        deleteMissionUseCase: DeleteMissionUseCase,
        networkMonitor: NetworkMonitor
    ) {
        self.missionRepository = missionRepository
        self.userRepository = userRepository
        self.refreshMissionsUseCase = refreshMissionsUseCase
        self.deleteMissionUseCase = deleteMissionUseCase
        self.networkMonitor = networkMonitor
        
        listenMissions()
        listenUser()
    }

    func refreshMissions() async {
        try? await refreshMissionsUseCase.execute()
    }
    
    func deleteMission(mission: Mission) {
        guard networkMonitor.isConnected else {
            return event = ErrorEvent(message: stringResource(.noInternetConectionError))
        }
        
        uiState.loading = true
        
        Task { @MainActor [weak self] in
            do {
                try await self?.deleteMissionUseCase.execute(mission: mission)
                self?.uiState.loading = false
            } catch {
                self?.uiState.loading = false
                self?.event = ErrorEvent(message: mapNetworkErrorMessage(error))
            }
        }
    }
    
    private func listenMissions() {
        missionRepository.missions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.uiState.missions = $0
            }.store(in: &cancellables)
    }
    
    private func listenUser() {
        userRepository.user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.uiState.user = user
            }
            .store(in: &cancellables)
    }
    
    struct MissionUiState {
        var user: User? = nil
        var missions: [Mission] = []
        var loading: Bool = false
    }
}
