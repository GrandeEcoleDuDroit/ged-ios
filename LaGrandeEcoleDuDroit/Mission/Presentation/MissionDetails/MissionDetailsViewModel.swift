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
        
        performRequest { [weak self] in
            try await self?.missionRepository.addParticipant(addMissionParticipant: addMissionparticipant)
        }
    }
    
    func unregisterFromMission() {
        guard let currentUser = uiState.currentUser else {
            return
        }
        
        performRequest { [weak self] in
            guard let self = self else { return }
            try await self.missionRepository.removeParticipant(missionId: self.missionId, userId: currentUser.id)
        }
    }
    
    func deleteMission() {
        guard let mission = uiState.mission else {
            return
        }
        
        performRequest { [weak self] in
            try await self?.deleteMissionUseCase.execute(mission: mission)
            self?.event = MissionDetailsUiEvent.missionDeleted
        }
    }
    
    func removeParticipant(userId: String) {
        guard let missionId = uiState.mission?.id,
              let userId = uiState.currentUser?.id
        else { return }
        
        performRequest { [weak self] in
            try await self?.missionRepository.removeParticipant(missionId: missionId, userId: userId)
        }
    }
    
    func reportMission(report: MissionReport) {
        performRequest { [weak self] in
            try await self?.missionRepository.reportMission(report: report)
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
    
    private func updateButtonState(user: User, mission: Mission, isManager: Bool) -> MissionButtonState? {
        if isManager {
            return nil
        }
        else if mission.completed {
            return MissionButtonState.completed
        }
        else if mission.participants.contains(where: { $0.id == user.id }) {
            return MissionButtonState.registered
        }
        else if !mission.schoolLevels.contains(user.schoolLevel) {
            let formattedSchoolLevels = mission.schoolLevels
                .sorted { $0.number < $1.number }
                .map { $0.rawValue }
                .joined(separator: ", ")
            return MissionButtonState.unavailable(reason: stringResource(.nonMatchingSchoolLevelInformationText, formattedSchoolLevels))
        }
        else if mission.full {
            return MissionButtonState.registrationClosed(reason: stringResource(.fullMissionInformationText))
        }
        else {
            return MissionButtonState.register
        }
    }
    
    struct MissionDetailsUiState: Copying {
        fileprivate(set) var currentUser: User? = nil
        fileprivate(set) var mission: Mission? = nil
        fileprivate(set) var isManager: Bool = false
        fileprivate(set) var loading: Bool = false
        fileprivate(set) var buttonState: MissionButtonState? = nil
    }
    
    enum MissionDetailsUiEvent: SingleUiEvent {
        case missionDeleted
    }
    
    enum MissionButtonState: Equatable {
        case register
        case registered
        case completed
        case registrationClosed(reason: String)
        case unavailable(reason: String)
    }
}
