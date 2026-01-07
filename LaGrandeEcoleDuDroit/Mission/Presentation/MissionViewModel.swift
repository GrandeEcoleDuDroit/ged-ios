import Combine
import Foundation

class MissionViewModel: ViewModel {
    private let missionRepository: MissionRepository
    private let userRepository: UserRepository
    private let refreshMissionsUseCase: RefreshMissionsUseCase
    private let deleteMissionUseCase: DeleteMissionUseCase
    private let recreateMissionUseCase: RecreateMissionUseCase
    private let networkMonitor: NetworkMonitor
    
    @Published private(set) var uiState = MissionUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private var cancellables: Set<AnyCancellable> = []

    init(
        missionRepository: MissionRepository,
        userRepository: UserRepository,
        refreshMissionsUseCase: RefreshMissionsUseCase,
        deleteMissionUseCase: DeleteMissionUseCase,
        recreateMissionUseCase: RecreateMissionUseCase,
        networkMonitor: NetworkMonitor
    ) {
        self.missionRepository = missionRepository
        self.userRepository = userRepository
        self.refreshMissionsUseCase = refreshMissionsUseCase
        self.deleteMissionUseCase = deleteMissionUseCase
        self.recreateMissionUseCase = recreateMissionUseCase
        self.networkMonitor = networkMonitor
        
        listenMissions()
        listenUser()
    }

    func refreshMissions() async {
        try? await refreshMissionsUseCase.execute()
    }
    
    func deleteMission(mission: Mission) {
        performRequest { [weak self] in
            try await self?.deleteMissionUseCase.execute(mission: mission)
        }
    }
    
    func reportMission(report: MissionReport) {
        performRequest { [weak self] in
            try await self?.missionRepository.reportMission(report: report)
        }
    }
    
    func recreateMission(mission: Mission) {
        Task {
            await recreateMissionUseCase.execute(mission: mission)
        }
    }
    
    private func performRequest(block: @escaping () async throws -> Void) {
        performUiBlockingRequest(
            block: block,
            onLoading: { [weak self] in
                self?.uiState.loading = true
            },
            onError: { [weak self] in
                self?.event = ErrorEvent(message: mapNetworkErrorMessage($0))
            },
            onFinally: { [weak self] in
                self?.uiState.loading = false
            }
        )
    }
    
    private func listenMissions() {
        missionRepository.missions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.uiState.missions = $0.missionSorting()
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
