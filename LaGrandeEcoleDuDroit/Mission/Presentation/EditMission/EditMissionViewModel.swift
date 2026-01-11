import Foundation
import Combine

class EditMissionViewModel: ViewModel {
    private let mission: Mission
    private let userRepository: UserRepository
    private let updateMissionUseCase: UpdateMissionUseCase
    private let getUsersUseCase: GetUsersUseCase
    private let generateIdUseCase: GenerateIdUseCase

    @Published var uiState = EditMissionUiState()
    @Published private(set) var event: SingleUiEvent?
    private var defaultUsers: [User] = []
    private let missionUpdateState = CurrentValueSubject<EditMissionViewModel.MissionUpdateState, Never>(MissionUpdateState())
    private var cancellables: Set<AnyCancellable> = []
    
    init(
        mission: Mission,
        userRepository: UserRepository,
        updateMissionUseCase: UpdateMissionUseCase,
        getUsersUseCase: GetUsersUseCase,
        generateIdUseCase: GenerateIdUseCase
    ) {
        self.mission = mission
        self.userRepository = userRepository
        self.updateMissionUseCase = updateMissionUseCase
        self.getUsersUseCase = getUsersUseCase
        self.generateIdUseCase = generateIdUseCase

        initUiState()
        initUsers()
        listenMissionUpdateState()
    }
    
    func updateMission(imageData: Data?) {
        let (
            title,
            description,
            startDate,
            endDate,
            schoolLevels,
            duration,
            managers,
            maxParticipants,
            missionTasks,
            missionState
        ) = (
            uiState.title.trim(),
            uiState.description.trim(),
            uiState.startDate,
            uiState.endDate,
            uiState.selectedSchoolLevels,
            uiState.duration.takeIf { $0.isNotBlank() }?.trim(),
            uiState.managers,
            uiState.maxParticipants.trim(),
            uiState.missionTasks,
            uiState.missionState
        )
        
        guard validateInputs(maxParticipants: maxParticipants) else { return }
        
        let missionToUpdate = mission.copy {
            $0.title = title
            $0.description = description
            $0.startDate = startDate
            $0.endDate = endDate
            $0.schoolLevels = schoolLevels
            $0.duration = duration
            $0.managers = managers
            $0.maxParticipants = maxParticipants.toInt()
            $0.tasks = missionTasks
            $0.state = missionState
        }
        
        performRequest { [weak self] in
            try await self?.updateMissionUseCase.execute(mission: missionToUpdate, imageData: imageData)
            self?.event = SuccessEvent()
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
    
    func onTitleChange(_ title: String) -> Void {
        let truncatedTitle = title.take(MissionUtilsPresentation.maxTitleLength)
        uiState.title = truncatedTitle
        missionUpdateState.send(
            missionUpdateState.value.copy {
                $0.titleUpdated = validateTitleUpdate(truncatedTitle)
            }
        )
    }
    
    func onDescriptionChange(_ description: String) -> Void {
        let truncatedDescription = description.take(MissionUtilsPresentation.maxDescriptionLength)
        uiState.description = truncatedDescription
        missionUpdateState.send(
            missionUpdateState.value.copy {
                $0.descriptionUpdated = validateDescriptionUpdate(truncatedDescription)
            }
        )
    }
    
    func onStartDateChange(_ startDate: Date) {
        uiState.startDate = startDate
        if !validateEndDateUpdate(startDate: startDate, endDate: uiState.endDate) {
            uiState.endDate = startDate
        }
        missionUpdateState.send(
            missionUpdateState.value.copy {
                $0.startDateUpdated = validateStartDateUpdate(startDate)
            }
        )
    }
    
    func onEndDateChange(_ endDate: Date) {
        let endDateValid = validateEndDateUpdate(startDate: uiState.startDate, endDate: endDate)
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
        var schoolLevels = uiState.selectedSchoolLevels
        if let index = schoolLevels.firstIndex(of: schoolLevel) {
            schoolLevels.remove(at: index)
        } else {
            schoolLevels.append(schoolLevel)
        }
        
        schoolLevels = schoolLevels.sorted { $0.number < $1.number }
        uiState.selectedSchoolLevels = schoolLevels
        uiState.schoolLevelSupportingText = showSchoolLevelSupportingText(schoolLevels: schoolLevels) ? stringResource(.editMissionSchoolLevelSupportingText) : nil
        missionUpdateState.send(
            missionUpdateState.value.copy {
                $0.schoolLevelsUpdated = validateSchoolLevelsUpdate(schoolLevels)
            }
        )
    }
    
    private func showSchoolLevelSupportingText(schoolLevels: [SchoolLevel]) -> Bool {
        !schoolLevels.isEmpty &&
        schoolLevels.count < SchoolLevel.all.count &&
        schoolLevels != mission.schoolLevels
    }
    
    func onMaxParticipantsChange(_ maxParticipants: String) -> Void {
        let maxParticipantsNumber = maxParticipants.toInt32OrDefault(-1)

        let value = switch maxParticipants {
            case _ where maxParticipants.isEmpty: ""
            case _ where maxParticipantsNumber > 0: maxParticipantsNumber.description
            default: uiState.previousMaxParticipants
        }
        
        uiState.previousMaxParticipants = value
        uiState.maxParticipants = value
        missionUpdateState.send(
            missionUpdateState.value.copy {
                $0.maxParticipantsUpdated = validateMaxParticipantsUpdate(value)
            }
        )
    }
    
    func onDurationChange(_ duration: String) -> Void {
        let truncatedDuration = duration.take(MissionUtilsPresentation.maxDurationLength)
        uiState.duration = truncatedDuration
        missionUpdateState.send(
            missionUpdateState.value.copy {
                $0.durationUpdated = validateDurationUpdate(truncatedDuration)
            }
        )
    }
    
    func onSaveManagers(_ managers: [User]) {
        uiState.managers = managers
        missionUpdateState.send(
            missionUpdateState.value.copy {
                $0.managersUpdated = validateManagersUpdate(managers)
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
                    $0.managersUpdated = validateManagersUpdate(managers)
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
                $0.missionTasksUpdated = validateMissionTasksUpdate(missionTasks)
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
                $0.missionTasksUpdated = validateMissionTasksUpdate(missionTasks)
            }
        )
    }
    
    func onRemoveMissionTask(_ missionTask: MissionTask) {
        var missionTasks = uiState.missionTasks
        missionTasks.remove(missionTask)
        uiState.missionTasks = missionTasks
        missionUpdateState.send(
            missionUpdateState.value.copy {
                $0.missionTasksUpdated = validateMissionTasksUpdate(missionTasks)
            }
        )
    }
    
    private func validateInputs(maxParticipants: String) -> Bool {
        uiState.maxParticipantsError = validateMaxParticipants(maxParticipants: maxParticipants)
        return uiState.maxParticipantsError == nil
    }
    
    private func validateRemovedImage() -> Bool {
        if case let .published(imageUrl) = mission.state {
            imageUrl != nil
        } else {
            false
        }
    }
    
    private func validateTitleUpdate(_ title: String) -> Bool {
        title != mission.title && title.isNotBlank()
    }
    
    private func validateDescriptionUpdate(_ description: String) -> Bool {
        description != mission.description && description.isNotBlank()
    }
    
    private func validateStartDateUpdate(_ startDate: Date) -> Bool {
        startDate != mission.startDate
    }
    
    private func validateEndDateUpdate(startDate: Date, endDate: Date) -> Bool {
        endDate != mission.endDate &&
            (endDate.isAlmostEqual(to: startDate) || endDate.isAfter(to: startDate))
    }
    
    private func validateSchoolLevelsUpdate(_ schoolLevels: [SchoolLevel]) -> Bool {
        schoolLevels != mission.schoolLevels && !schoolLevels.isEmpty
    }
    
    private func validateMaxParticipantsUpdate(_ maxParticipants: String) -> Bool {
        maxParticipants != mission.maxParticipants.description && maxParticipants.isNotBlank()
    }
    
    private func validateDurationUpdate(_ duration: String) -> Bool {
        duration != mission.duration.orEmpty()
    }
    
    private func validateManagersUpdate(_ managers: [User]) -> Bool {
        managers != mission.managers
    }
    
    private func validateMissionTasksUpdate(_ missionTasks: [MissionTask]) -> Bool {
        missionTasks != mission.tasks
    }
    
    private func validateMaxParticipants(maxParticipants: String) -> String? {
        let maxParticipantsNumber = maxParticipants.toInt32OrDefault(-1)
        
        return switch maxParticipantsNumber {
            case _ where maxParticipants.isEmpty: stringResource(.mandatoryFieldError)
                
            case _ where maxParticipantsNumber <= 0: stringResource(.numberFieldError)
            
            case _ where maxParticipantsNumber < mission.participants.count:
                stringResource(.maxParticipantsLowerThanCurrentError, mission.participants.count)
                
            default: nil
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
        uiState.selectedSchoolLevels = mission.schoolLevels
        uiState.duration = mission.duration.orEmpty()
        uiState.managers = mission.managers
        uiState.maxParticipants = mission.maxParticipants.description
        uiState.previousMaxParticipants = mission.maxParticipants.description
        uiState.missionTasks = mission.tasks
        uiState.missionState = mission.state
    }
    
    
    private func initUsers() {
        let mission = mission
        let managersMap = mission.managers.reduce(into: [String: User]()) { result, manager in
            result[manager.id] = manager
        }
        
        Task { @MainActor [weak self] in
            guard var users = await self?.getUsersUseCase.execute()
                .filter({ !managersMap.has($0.id) })
            else { return }
            
            users.append(contentsOf: mission.managers)
            users = users.missionManagerSorting(mission: mission)
            self?.uiState.users = users
            self?.defaultUsers = users
        }
    }
    
    struct EditMissionUiState {
        var title: String = ""
        var description: String = ""
        fileprivate(set) var startDate: Date = Date()
        fileprivate(set) var endDate: Date = Date()
        fileprivate(set) var selectedSchoolLevels: [SchoolLevel] = []
        let allSchoolLevels: [SchoolLevel] = SchoolLevel.all
        fileprivate(set) var managers: [User] = []
        var maxParticipants: String = ""
        fileprivate(set) var previousMaxParticipants: String = ""
        var duration: String = ""
        fileprivate(set) var missionTasks: [MissionTask] = []
        fileprivate(set) var users: [User] = []
        fileprivate(set) var userQuery: String = ""
        fileprivate(set) var loading: Bool = false
        fileprivate(set) var missionState: Mission.MissionState = .draft
        fileprivate(set) var updateEnabled: Bool = false
        fileprivate(set) var schoolLevelSupportingText: String? = nil
        
        fileprivate(set) var maxParticipantsError: String? = nil
    }
    
    private struct MissionUpdateState: Copying {
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
