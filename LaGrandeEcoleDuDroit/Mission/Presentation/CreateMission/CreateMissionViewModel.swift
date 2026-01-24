import Foundation
import Combine

class CreateMissionViewModel: ViewModel {
    private let userRepository: UserRepository
    private let createMissionUseCase: CreateMissionUseCase
    private let getUsersUseCase: GetUsersUseCase
    private let generateIdUseCase: GenerateIdUseCase
    
    @Published var uiState = CreateMissionUiState()
    @Published var event: SingleUiEvent?
    private var cancellable: AnyCancellable?
    
    init(
        userRepository: UserRepository,
        createMissionUseCase: CreateMissionUseCase,
        getUsersUseCase: GetUsersUseCase,
        generateIdUseCase: GenerateIdUseCase
    ) {
        self.userRepository = userRepository
        self.createMissionUseCase = createMissionUseCase
        self.getUsersUseCase = getUsersUseCase
        self.generateIdUseCase = generateIdUseCase
        
        initCurrentUser()
        initUsers()
    }
    
    func createMission(imageData: Data?) {
        let (
            title,
            description,
            startDate,
            endDate,
            schoolLevels,
            duration,
            managers,
            maxParticipants,
            missionTasks
        ) = (
            uiState.title.trim(),
            uiState.description.trim(),
            uiState.startDate,
            uiState.endDate,
            uiState.selectedSchoolLevels,
            uiState.duration.takeIf { $0.isNotBlank() }?.trim(),
            uiState.managers,
            uiState.maxParticipants.trim(),
            uiState.missionTasks
        )
        
        guard validateInputs(maxParticipants: maxParticipants) else { return }
        
        let mission = Mission(
            id: generateIdUseCase.execute(),
            title: title,
            description: description,
            date: Date(),
            startDate: startDate,
            endDate: endDate,
            schoolLevels: schoolLevels,
            duration: duration,
            managers: managers,
            participants: [],
            maxParticipants: maxParticipants.toInt(),
            tasks: missionTasks,
            state: .draft
        )
        
        Task {
            await createMissionUseCase.execute(mission: mission, imageData: imageData)
        }
        
        event = SuccessEvent()
    }
    
    func onTitleChange(_ title: String) -> Void {
        let truncatedTitle = title.take(MissionUtilsPresentation.maxTitleLength)
        uiState.title = truncatedTitle
        uiState.createEnabled = validateCreate(title: truncatedTitle)
    }
    
    func onDescriptionChange(_ description: String) -> Void {
        let truncatedDescription = description.take(MissionUtilsPresentation.maxDescriptionLength)
        uiState.description = truncatedDescription
        uiState.createEnabled = validateCreate(description: truncatedDescription)
    }
    
    func onStartDateChange(_ startDate: Date) {
        uiState.startDate = startDate
        if !validateEndDate(startDate: startDate, endDate: uiState.endDate) {
            uiState.endDate = startDate
        }
    }
    
    func onEndDateChange(_ endDate: Date) {
        uiState.endDate = endDate
        if !validateEndDate(startDate: uiState.startDate, endDate: endDate) {
            uiState.startDate =  endDate
        }
    }
    
    func onSchoolLevelChange(_ schoolLevel: SchoolLevel) {
        var schoolLevels = uiState.selectedSchoolLevels
        
        if let index = schoolLevels.firstIndex(of: schoolLevel) {
            schoolLevels.remove(at: index)
        } else {
            schoolLevels.append(schoolLevel)
        }
        
        uiState.selectedSchoolLevels = schoolLevels.sorted { $0.number < $1.number }
        uiState.createEnabled = validateCreate()
    }
    
    func onMaxParticipantsChange(_ maxParticipants: String) -> Void {
        let maxParticipantsNumber = maxParticipants.toInt32OrDefault(-1)
        let validMaxParticipantsNumber = maxParticipantsNumber > 0 && maxParticipantsNumber.description.count <= MissionUtilsPresentation.maxParticipantsLength

        let value = switch maxParticipants {
            case _ where maxParticipants.isEmpty: ""
            case _ where validMaxParticipantsNumber: maxParticipantsNumber.description
            default: uiState.previousMaxParticipants
        }
        
        uiState.previousMaxParticipants = value
        uiState.maxParticipants = value
        uiState.createEnabled = validateCreate(maxParticipants: value)
    }
    
    func onDurationChange(_ duration: String) -> Void {
        uiState.duration = duration.take(MissionUtilsPresentation.maxDurationLength)
    }
    
    func onUpdateManagers(_ managers: [User]) {
        uiState.managers = managers
    }
    
    func onRemoveManager(_ manager: User) {
        var managers = uiState.managers
        if managers.count > 1 {
            managers.remove(manager)
            uiState.managers = managers
        }
    }
    
    func onAddMissionTask(_ missionTaskValue: String) {
        let task = MissionTask(id: generateIdUseCase.execute(), value: missionTaskValue)
        uiState.missionTasks.append(task)
    }
    
    func onUpdateMissionTask(_ missionTask: MissionTask) {
        let trimmedMissionTask = missionTask.copy { $0.value = missionTask.value.trim() }
        let missionTasks = uiState.missionTasks.replace(
            where: { $0.id == missionTask.id },
            with: trimmedMissionTask
        )
        uiState.missionTasks = missionTasks
    }
    
    func onRemoveMissionTask(_ missionTask: MissionTask) {
        uiState.missionTasks.remove(missionTask)
    }
    
    private func validateInputs(maxParticipants: String) -> Bool {
        validateMaxParticipants(maxParticipants)
    }
    
    private func validateCreate(
        title: String? = nil,
        description: String? = nil,
        selectedSchoolLevels: [SchoolLevel]? = nil,
        maxParticipants: String? = nil
    ) -> Bool {
        (title ?? uiState.title).isNotBlank() &&
            (description ?? uiState.description).isNotBlank() &&
            !(selectedSchoolLevels ?? uiState.selectedSchoolLevels).isEmpty &&
            (maxParticipants ?? uiState.maxParticipants).isNotBlank()
    }
    
    private func validateEndDate(startDate: Date?, endDate: Date?) -> Bool {
        (endDate ?? uiState.endDate) >= (startDate ?? uiState.startDate)
    }
    
    private func validateMaxParticipants(_ maxParticipants: String) -> Bool {
        uiState.maxParticipantsError = switch maxParticipants {
            case _ where maxParticipants.isEmpty: stringResource(.mandatoryFieldError)
            case _ where maxParticipants.toInt32OrDefault(-1) <= 0: stringResource(.numberFieldError)
            default: nil
        }
        
        return uiState.maxParticipantsError == nil
    }
    
    private func initCurrentUser() {
        cancellable = userRepository.user.first().sink { [weak self] user in
            self?.uiState.user = user
            self?.uiState.managers = [user]
        }
    }
    
    private func initUsers() {
        Task { @MainActor [weak self] in
            if let users = await self?.getUsersUseCase.execute().missionManagerSorting() {
                self?.uiState.users = users
            }
        }
    }
    
    struct CreateMissionUiState {
        var title: String = ""
        var description: String = ""
        fileprivate(set) var startDate: Date = Date()
        fileprivate(set) var endDate: Date = Date()
        fileprivate(set) var selectedSchoolLevels: [SchoolLevel] = SchoolLevel.all
        let allSchoolLevels: [SchoolLevel] = SchoolLevel.all
        fileprivate(set) var managers: [User] = []
        var maxParticipants: String = ""
        fileprivate(set) var previousMaxParticipants: String = ""
        var duration: String = ""
        fileprivate(set) var missionTasks: [MissionTask] = []
        fileprivate(set) var user: User?
        fileprivate(set) var users: [User] = []
        fileprivate(set) var createEnabled: Bool = false
        
        fileprivate(set) var maxParticipantsError: String?
    }
}
