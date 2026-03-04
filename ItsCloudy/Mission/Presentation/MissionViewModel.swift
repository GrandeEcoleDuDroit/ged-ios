import Combine
import Foundation

class MissionViewModel: ViewModel {
    private let missionRepository: MissionRepository
    private let userRepository: UserRepository
    private let refreshMissionsUseCase: RefreshMissionsUseCase
    private let deleteMissionUseCase: DeleteMissionUseCase
    private let recreateMissionUseCase: RecreateMissionUseCase
    
    @Published private(set) var uiState = MissionUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private var cancellables: Set<AnyCancellable> = []
    private var defaultMissions: [Mission] = []

    init(
        missionRepository: MissionRepository,
        userRepository: UserRepository,
        refreshMissionsUseCase: RefreshMissionsUseCase,
        deleteMissionUseCase: DeleteMissionUseCase,
        recreateMissionUseCase: RecreateMissionUseCase
    ) {
        self.missionRepository = missionRepository
        self.userRepository = userRepository
        self.refreshMissionsUseCase = refreshMissionsUseCase
        self.deleteMissionUseCase = deleteMissionUseCase
        self.recreateMissionUseCase = recreateMissionUseCase
        
        listenMissions()
        listenUser()
    }
    
    func onMissionFilterChange(_ filter: MissionFilter) {
        updateMissions(filter: filter)
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
    
    private func updateMissions(filter: MissionFilter? = nil) {
        let activeFilter = filter ?? uiState.activeFilter
        switch activeFilter {
            case .open:
                uiState.activeFilter = activeFilter
                uiState.missions = defaultMissions.filter { !$0.completed }
                
            case .all:
                uiState.activeFilter = activeFilter
                uiState.missions = defaultMissions
        }
    }
    
    private func performRequest(block: @escaping () async throws -> Void) {
        performUiBlockingRequest(
            block: block,
            onLoading: { [weak self] in
                self?.uiState.loading = true
            },
            onError: { [weak self] in
                self?.event = ErrorEvent(message: $0.localizedDescription)
            },
            onFinshed: { [weak self] in
                self?.uiState.loading = false
            }
        )
    }
    
    private func listenMissions() {
        missionRepository.missions
            .receive(on: DispatchQueue.main)
            .map { $0.missionSorting() }
            .sink { [weak self] in
                self?.defaultMissions = $0
                self?.updateMissions()
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
        fileprivate(set) var activeFilter: MissionFilter = .open
        fileprivate(set) var filters: [MissionFilter] = MissionFilter.allCases
    }
    
    enum MissionFilter: CaseIterable {
        case open
        case all
        
        var label: String {
            switch self {
                case .open: stringResource(.open)
                case .all: stringResource(.all)
            }
        }
    }
}
