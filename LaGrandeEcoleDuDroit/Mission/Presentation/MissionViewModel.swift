import Combine
import Foundation

class MissionViewModel: ViewModel {
    private let missionRepository: MissionRepository
    private let userRepository: UserRepository
    private let refreshMissionsUseCase: RefreshMissionsUseCase
    private let deleteMissionUseCase: DeleteMissionUseCase
    private let resendMissionUseCase: ResendMissionUseCase
    private let networkMonitor: NetworkMonitor
    
    @Published private(set) var uiState = MissionUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private var cancellables: Set<AnyCancellable> = []

    init(
        missionRepository: MissionRepository,
        userRepository: UserRepository,
        refreshMissionsUseCase: RefreshMissionsUseCase,
        deleteMissionUseCase: DeleteMissionUseCase,
        resendMissionUseCase: ResendMissionUseCase,
        networkMonitor: NetworkMonitor
    ) {
        self.missionRepository = missionRepository
        self.userRepository = userRepository
        self.refreshMissionsUseCase = refreshMissionsUseCase
        self.deleteMissionUseCase = deleteMissionUseCase
        self.resendMissionUseCase = resendMissionUseCase
        self.networkMonitor = networkMonitor
        
        listenMissions()
        listenUser()
    }

    func refreshMissions() async {
        try? await refreshMissionsUseCase.execute()
    }
    
    func deleteMission(mission: Mission) {
        uiState.loading = true
        
        Task { @MainActor [weak self] in
            do {
                try await self?.deleteMissionUseCase.execute(mission: mission)
                self?.uiState.loading = false
            } catch {
                self?.uiState.loading = false
                self?.event = ErrorEvent(
                    message: mapNetworkErrorMessage(
                        error,
                        specificMap: { stringResource(.unknownError) }
                    )
                )
            }
        }
    }
    
    func reportMission(report: MissionReport) {
        executeRequest { [weak self] in
            try await self?.missionRepository.reportMission(report: report)
        }
    }
    
    func resendMission(mission: Mission) {
        Task {
            await resendMissionUseCase.execute(mission: mission)
        }
    }
    
    private func executeRequest(block: @escaping () async throws -> Void) {
        var loadingTask: Task<Void, Error>?
        
        Task { @MainActor in
            do {
                if !networkMonitor.isConnected {
                    throw NetworkError.noInternetConnection
                }
                
                loadingTask = Task { @MainActor in
                    try await Task.sleep(for: .milliseconds(300))
                    uiState.loading = true
                }
                
                try await block()
            } catch {
                event = ErrorEvent(message: mapNetworkErrorMessage(error))
            }
            
            loadingTask?.cancel()
            uiState.loading = false
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
        fileprivate(set) var user: User? = nil
        fileprivate(set) var missions: [Mission] = []
        fileprivate(set) var loading: Bool = false
    }
}
