import Foundation
import Combine

class EditMissionViewModel: ViewModel {
    private let mission: Mission
    private let userRepository: UserRepository
    private let updateMissionUseCase: UpdateMissionUseCase
    private let getUsersUseCase: GetUsersUseCase
    private let generateIdUseCase: GenerateIdUseCase
    private let networkMonitor: NetworkMonitor

    @Published private(set) var uiState = EditMissionUiState()
    @Published private(set) var event: SingleUiEvent?
    private var defaultUsers: [User] = []
    private let missionUpdateState = CurrentValueSubject<EditMissionViewModel.MissionUpdateState, Never>(MissionUpdateState())
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        mission: Mission,
        userRepository: UserRepository,
        updateMissionUseCase: UpdateMissionUseCase,
        getUsersUseCase: GetUsersUseCase,
        generateIdUseCase: GenerateIdUseCase,
        networkMonitor: NetworkMonitor
    ) {
        self.mission = mission
        self.userRepository = userRepository
        self.updateMissionUseCase = updateMissionUseCase
        self.getUsersUseCase = getUsersUseCase
        self.generateIdUseCase = generateIdUseCase
        self.networkMonitor = networkMonitor

        initUiState()
        initUsers()
        listenMissionUpdateState()
    }
    
    func updateMission(imageData: Data?) {
        guard uiState.updateEnabled else { return }
        
        let newMission = mission.copy {
            $0.title = uiState.title.trim()
            $0.description = uiState.description.trim()
            $0.startDate = uiState.startDate
            $0.endDate = uiState.endDate
            $0.schoolLevels = uiState.schoolLevels
            $0.duration = uiState.duration.takeIf { $0.isNotBlank() }?.trim()
            $0.managers = uiState.managers
            $0.maxParticipants = uiState.maxParticipants.trim().toInt()
            $0.tasks = uiState.missionTasks
            $0.state = uiState.missionState
        }
        
        executeRequest { [weak self] in
            guard let self else { return }
            try await updateMissionUseCase.execute(
                mission: newMission,
                imageData: imageData,
                previousMissionState: self.mission.state
            )
            event = SuccessEvent()
        }
    }
    
    func onImageChange() {
        uiState.missionState = switch mission.state {
            case .draft: .draft
            case .publishing: .publishing(imagePath: nil)
            case .published: .published(imageUrl: nil)
            case .error: .error(imagePath: nil)
        }
        missionUpdateState.send(
            missionUpdateState.value.copy {
                $0.imageUpdated = true
            }
        )
    }
    
    func onImageRemove() {
        uiState.missionState = switch mission.state {
            case .draft: .draft
            case .publishing: .publishing(imagePath: nil)
            case .published: .published(imageUrl: nil)
            case .error: .error(imagePath: nil)
        }
        missionUpdateState.send(
            missionUpdateState.value.copy {
                $0.imageUpdated = validateRemovedImage()
            }
        )
    }
    
    func onTitleChange(_ title: String) -> String {
        let truncatedTitle = title.take(MissionPresentationUtils.maxTitleLength)
        uiState.title = truncatedTitle
        missionUpdateState.send(
            missionUpdateState.value.copy {
                $0.titleUpdated = validateTitle(truncatedTitle)
            }
        )
        
        return truncatedTitle
    }
    
    func onDescriptionChange(_ description: String) -> String {
        let truncatedDescription = description.take(MissionPresentationUtils.maxDescriptionLength)
        uiState.description = truncatedDescription
        missionUpdateState.send(
            missionUpdateState.value.copy {
                $0.descriptionUpdated = validateDescription(truncatedDescription)
            }
        )
        
        return truncatedDescription
    }
    
    func onStartDateChange(_ startDate: Date) {
        uiState.startDate = startDate
        if !validateEndDate(startDate: startDate, endDate: uiState.endDate) {
            uiState.endDate = startDate
        }
        missionUpdateState.send(
            missionUpdateState.value.copy {
                $0.startDateUpdated = validateStartDate(startDate)
            }
        )
    }
    
    func onEndDateChange(_ endDate: Date) {
        let endDateValid = validateEndDate(startDate: uiState.startDate, endDate: endDate)
        uiState.endDate = endDate
        if !endDateValid {
            uiState.startDate =  endDate
        }
        missionUpdateState.send(
            missionUpdateState.value.copy {
                $0.endDateUpdated = endDateValid
            }
        )
    }
    
    func onSchoolLevelChange(_ schoolLevel: SchoolLevel) {
        var schoolLevels = uiState.schoolLevels
        if let index = schoolLevels.firstIndex(of: schoolLevel) {
            schoolLevels.remove(at: index)
        } else {
            schoolLevels.append(schoolLevel)
        }
        schoolLevels = schoolLevels.sorted { $0.number < $1.number }
        
        uiState.schoolLevels = schoolLevels
        missionUpdateState.send(
            missionUpdateState.value.copy {
                $0.schoolLevelsUpdated = validateSchoolLevels(schoolLevels)
            }
        )
        
        if schoolLevels != mission.schoolLevels &&
            !schoolLevels.isEmpty &&
            schoolLevels.count < SchoolLevel.allCases.count
        {
            uiState.schoolLevelSupportingText = stringResource(.editMissionSchoolLevelSupportingText)
        } else {
            uiState.schoolLevelSupportingText = nil
        }
    }
    
    func onMaxParticipantsChange(_ maxParticipants: String) -> String {
        let value = switch maxParticipants {
            case _ where maxParticipants.isEmpty: ""
            case _ where maxParticipants.toInt32OrDefault(-1) > 0: maxParticipants
            default: uiState.maxParticipants
        }
        
        uiState.maxParticipants = value
        missionUpdateState.send(
            missionUpdateState.value.copy {
                $0.maxParticipantsUpdated = validateMaxParticipants(maxParticipants)
            }
        )
        
        return value
    }
    
    func onDurationChange(_ duration: String) -> String {
        let truncatedDuration = duration.take(MissionPresentationUtils.maxDurationLength)
        uiState.duration = truncatedDuration
        missionUpdateState.send(
            missionUpdateState.value.copy {
                $0.durationUpdated = validateDuration(truncatedDuration)
            }
        )
        
        return truncatedDuration
    }
    
    func onSaveManagers(_ managers: [User]) {
        uiState.managers = managers
        missionUpdateState.send(
            missionUpdateState.value.copy {
                $0.managersUpdated = validateManagers(managers)
            }
        )
    }
    
    func onRemoveManager(_ manager: User) {
        var managers = uiState.managers
        if managers.count > 1 {
            managers.remove(manager)
            uiState.managers = managers
            missionUpdateState.send(
                missionUpdateState.value.copy {
                    $0.managersUpdated = validateManagers(managers)
                }
            )
        }
    }
    
    func onUserQueryChange(_ query: String) {
        uiState.userQuery = query
        filterUsersByName(query)
    }
    
    private func filterUsersByName(_ query: String) {
        let users = if query.isBlank() {
            defaultUsers
        } else {
            defaultUsers.filter {
                $0.fullName
                    .lowercased()
                    .contains(query.lowercased())
            }
        }
        
        uiState.users = users
    }
    
    func onAddMissionTask(_ value: String) {
        let missionTask = MissionTask(id: generateIdUseCase.execute(), value: value)
        var missionTasks = uiState.missionTasks
        missionTasks.append(missionTask)
        uiState.missionTasks = missionTasks
        missionUpdateState.send(
            missionUpdateState.value.copy {
                $0.missionTasksUpdated = validateMissionTasks(missionTasks)
            }
        )
    }
    
    func onEditMissionTask(_ missionTask: MissionTask) {
        let trimmedMissionTask = missionTask.copy { $0.value = missionTask.value.trim() }
        let missionTasks = uiState.missionTasks.replace(
            where: { $0.id == missionTask.id },
            with: trimmedMissionTask
        )
        uiState.missionTasks = missionTasks
        missionUpdateState.send(
            missionUpdateState.value.copy {
                $0.missionTasksUpdated = validateMissionTasks(missionTasks)
            }
        )
    }
    
    func onRemoveMissionTask(_ missionTask: MissionTask) {
        var missionTasks = uiState.missionTasks
        missionTasks.remove(missionTask)
        uiState.missionTasks = missionTasks
        missionUpdateState.send(
            missionUpdateState.value.copy {
                $0.missionTasksUpdated = validateMissionTasks(missionTasks)
            }
        )
    }
    
    private func validateRemovedImage() -> Bool {
        if case let .published(imageUrl) = mission.state {
            imageUrl != nil
        } else {
            false
        }
    }
    
    private func validateTitle(_ title: String) -> Bool {
        title != mission.title && title.isNotBlank()
    }
    
    private func validateDescription(_ description: String) -> Bool {
        description != mission.description && description.isNotBlank()
    }
    
    private func validateStartDate(_ startDate: Date) -> Bool {
        startDate != mission.startDate
    }
    
    private func validateEndDate(startDate: Date, endDate: Date) -> Bool {
        endDate != mission.endDate &&
            (endDate.isAlmostEqual(to: startDate) || endDate.isAlmostAfter(to: startDate))
    }
    
    private func validateSchoolLevels(_ schoolLevels: [SchoolLevel]) -> Bool {
        schoolLevels != mission.schoolLevels
    }
    
    private func validateMaxParticipants(_ maxParticipants: String) -> Bool {
        maxParticipants != mission.maxParticipants.description && maxParticipants.isNotBlank()
    }
    
    private func validateDuration(_ duration: String) -> Bool {
        duration != mission.duration.orEmpty()
    }
    
    private func validateManagers(_ managers: [User]) -> Bool {
        managers != mission.managers
    }
    
    private func validateMissionTasks(_ missionTasks: [MissionTask]) -> Bool {
        missionTasks != mission.tasks
    }
    
    private func validateMandatoryFields() -> Bool {
        uiState.title.isNotBlank() &&
            uiState.description.isNotBlank() &&
            uiState.maxParticipants.isNotBlank()
    }
    
    private func listenMissionUpdateState() {
        missionUpdateState.sink { [weak self] missionUpdateState in
            self?.uiState.updateEnabled = missionUpdateState.updated
        }.store(in: &cancellables)
    }
    
    private func initUiState() {
        uiState.title = mission.title
        uiState.description = mission.description
        uiState.startDate = mission.startDate
        uiState.endDate = mission.endDate
        uiState.schoolLevels = mission.schoolLevels
        uiState.duration = mission.duration.orEmpty()
        uiState.managers = mission.managers
        uiState.maxParticipants = mission.maxParticipants.description
        uiState.missionTasks = mission.tasks
        uiState.missionState = mission.state
    }
    
    
    private func initUsers() {
        Task { @MainActor [weak self] in
            guard let mission = self?.mission,
                  let users = await self?.getUsersUseCase.execute().missionManagerSorting(mission: mission)
            else { return }
            
            self?.uiState.users = users
            self?.defaultUsers = users
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
    
    struct EditMissionUiState {
        fileprivate(set) var title: String = ""
        fileprivate(set) var description: String = ""
        fileprivate(set) var startDate: Date = Date()
        fileprivate(set) var endDate: Date = Date()
        let allSchoolLevels: [SchoolLevel] = SchoolLevel.allCases
        fileprivate(set) var schoolLevels: [SchoolLevel] = []
        fileprivate(set) var duration: String = ""
        fileprivate(set) var managers: [User] = []
        fileprivate(set) var maxParticipants: String = ""
        fileprivate(set) var missionTasks: [MissionTask] = []
        fileprivate(set) var users: [User] = []
        fileprivate(set) var userQuery: String = ""
        fileprivate(set) var loading: Bool = false
        fileprivate(set) var missionState: Mission.MissionState = .draft
        fileprivate(set) var updateEnabled: Bool = false
        fileprivate(set) var schoolLevelSupportingText: String? = nil
    }
    
    private struct MissionUpdateState: Copyable {
        var imageUpdated: Bool = false
        var titleUpdated: Bool = false
        var descriptionUpdated: Bool = false
        var startDateUpdated: Bool = false
        var endDateUpdated: Bool = false
        var schoolLevelsUpdated: Bool = false
        var maxParticipantsUpdated: Bool = false
        var durationUpdated: Bool = false
        var managersUpdated: Bool = false
        var missionTasksUpdated: Bool = false
        var imageModelUpdated: Bool = false
        var updated: Bool {
            imageUpdated ||
            titleUpdated ||
            descriptionUpdated ||
            startDateUpdated ||
            endDateUpdated ||
            schoolLevelsUpdated ||
            maxParticipantsUpdated ||
            durationUpdated ||
            managersUpdated ||
            missionTasksUpdated ||
            imageModelUpdated
        }
    }
}
