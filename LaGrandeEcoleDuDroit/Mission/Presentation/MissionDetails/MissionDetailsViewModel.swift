import Combine
import Foundation

class MissionDetailsViewModel: ViewModel {
    private let missionId: String
    private let missionRepository: MissionRepository
    private let userRepository: UserRepository
    private let networkMonitor: NetworkMonitor
    private let deleteMissionUseCase: DeleteMissionUseCase
    
    @Published private(set) var uiState = MissionDetailsUiState()
    @Published private(set) var event: SingleUiEvent? = nil
    private var cancellables = Set<AnyCancellable>()

    init(
        missionId: String,
        missionRepository: MissionRepository,
        userRepository: UserRepository,
        networkMonitor: NetworkMonitor,
        deleteMissionUseCase: DeleteMissionUseCase
    ) {
        self.missionId = missionId
        self.missionRepository = missionRepository
        self.userRepository = userRepository
        self.networkMonitor = networkMonitor
        self.deleteMissionUseCase = deleteMissionUseCase
        
        listenUserAndMission()
    }
    
    func registerToMission() {
        guard let currentUser = uiState.currentUser,
              let mission = uiState.mission
        else { return }
        
        let addMissionparticipant = AddMissionParticipant(
            missionId: missionId,
            schoolLevels: mission.schoolLevels,
            maxParticipants: mission.maxParticipants,
            participantsNumber: mission.participants.count,
            user: currentUser
        )
        
        executeRequest { [weak self] in
            try await self?.missionRepository.addParticipant(addMissionParticipant: addMissionparticipant)
        }
    }
    
    func unregisterFromMission() {
        guard let currentUser = uiState.currentUser else {
            return
        }
        
        executeRequest { [weak self] in
            guard let self = self else { return }
            try await self.missionRepository.removeParticipant(missionId: self.missionId, userId: currentUser.id)
        }
    }
    
    func deleteMission() {
        guard let mission = uiState.mission else {
            return
        }
        
        executeRequest { [weak self] in
            try await self?.deleteMissionUseCase.execute(mission: mission)
            self?.event = MissionDetailsUiEvent.missionDeleted
        }
    }
    
    func removeParticipant(userId: String) {
        guard let missionId = uiState.mission?.id,
              let userId = uiState.currentUser?.id
        else { return }
        
        executeRequest { [weak self] in
            try await self?.missionRepository.removeParticipant(missionId: missionId, userId: userId)
        }
    }
    
    func reportMission(report: MissionReport) {
        executeRequest { [weak self] in
            try await self?.missionRepository.reportMission(report: report)
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
    
    private func listenUserAndMission() {
        Publishers.CombineLatest(
            userRepository.user,
            missionRepository.getMissionPublisher(missionId: missionId)
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] user, mission in
            guard let self else { return }
            let isManager = mission.managers.contains { $0.id == user.id }
            
            self.uiState.currentUser = user
            self.uiState.mission = mission
            self.uiState.isManager = isManager
            self.uiState.buttonState = self.updateButtonState(user: user, mission: mission, isManager: isManager)
        }.store(in: &cancellables)
    }
    
    private func updateButtonState(user: User, mission: Mission, isManager: Bool) -> MissionButtonState {
        if isManager {
            return MissionButtonState.hidden
        }
        else if mission.complete {
            return MissionButtonState.complete
        }
        else if mission.participants.contains(where: { $0.id == user.id }) {
            return MissionButtonState.registered
        }
        else {
            let enabled = !mission.full && mission.schoolLevelPermitted(schoolLevel: user.schoolLevel)
            return MissionButtonState.register(enabled: enabled)
        }
    }
    
    struct MissionDetailsUiState: Copying {
        fileprivate(set) var currentUser: User? = nil
        fileprivate(set) var mission: Mission? = nil
        fileprivate(set) var isManager: Bool = false
        fileprivate(set) var loading: Bool = false
        fileprivate(set) var buttonState: MissionButtonState = .hidden
    }
    
    enum MissionDetailsUiEvent: SingleUiEvent {
        case missionDeleted
    }
    
    enum MissionButtonState: Equatable {
        case register(enabled: Bool = true)
        case registered
        case complete
        case hidden
    }
}
