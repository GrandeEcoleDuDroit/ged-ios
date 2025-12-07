import Foundation
import Combine

class CreateMissionViewModel: ViewModel {
    private let userRepository: UserRepository
    private let createMissionUseCase: CreateMissionUseCase
    private let getUsersUseCase: GetUsersUseCase
    private let generateIdUseCase: GenerateIdUseCase
    
    @Published private(set) var uiState = CreateMissionUiState()
    private var defaultUsers: [User] = []
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
        let mission = Mission(
            id: generateIdUseCase.execute(),
            title: uiState.title.trim(),
            description: uiState.description.trim(),
            date: Date(),
            startDate: uiState.startDate,
            endDate: uiState.endDate,
            schoolLevels: uiState.schoolLevels,
            duration: uiState.duration.takeIf { $0.isNotBlank() }?.trim(),
            managers: uiState.managers,
            participants: [],
            maxParticipants: uiState.maxParticipants.trim().toInt(),
            tasks: uiState.missionTasks,
            state: .draft
        )
        
        Task {
            await createMissionUseCase.execute(mission: mission, imageData: imageData)
        }
    }
    
    func onTitleChange(_ title: String) -> String {
        let truncatedTitle = title.take(MissionPresentationUtils.maxTitleLength)
        uiState.title = truncatedTitle
        uiState.createEnabled = validateCreate(title: truncatedTitle)
        return truncatedTitle
    }
    
    func onDescriptionChange(_ description: String) -> String {
        let truncatedDescription = description.take(MissionPresentationUtils.maxDescriptionLength)
        uiState.description = truncatedDescription
        uiState.createEnabled = validateCreate(description: truncatedDescription)
        return truncatedDescription
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
        var schoolLevels = uiState.schoolLevels
        if let index = schoolLevels.firstIndex(of: schoolLevel) {
            schoolLevels.remove(at: index)
        } else {
            schoolLevels.append(schoolLevel)
        }
        schoolLevels = schoolLevels.sorted { $0.number < $1.number }
        
        uiState.schoolLevels = schoolLevels
    }
    
    func onMaxParticipantsChange(_ maxParticipants: String) -> String {
        let value = switch maxParticipants {
            case _ where maxParticipants.isEmpty: ""
            case _ where maxParticipants.toInt32OrDefault(-1) > 0: maxParticipants
            default: uiState.maxParticipants
        }
        
        uiState.maxParticipants = value
        uiState.createEnabled = validateCreate(maxParticipants: value)
        return value
    }
    
    func onDurationChange(_ duration: String) -> String {
        let truncatedDuration = duration.take(MissionPresentationUtils.maxDurationLength)
        uiState.duration = truncatedDuration
        return truncatedDuration
    }
    
    func onSaveManagers(_ managers: [User]) {
        uiState.managers = managers
    }
    
    func onRemoveManager(_ manager: User) {
        var managers = uiState.managers
        if managers.count > 1 {
            managers.remove(manager)
            uiState.managers = managers
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
    
    func onAddMissionTask(_ missionTaskValue: String) {
        let task = MissionTask(id: generateIdUseCase.execute(), value: missionTaskValue)
        uiState.missionTasks.append(task)
    }
    
    func onEditMissionTask(_ missionTask: MissionTask) {
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
    
    private func validateCreate(
        title: String? = nil,
        description: String? = nil,
        maxParticipants: String? = nil
    ) -> Bool {
        validateTitle(title) &&
            validateDescription(description) &&
            validateMaxParticipants(maxParticipants)
    }
    
    private func validateTitle(_ title: String?) -> Bool {
        (title ?? uiState.title).isNotBlank()
    }
    
    private func validateDescription(_ description: String?) -> Bool {
        (description ?? uiState.description).isNotBlank()
    }
    
    private func validateEndDate(startDate: Date?, endDate: Date?) -> Bool {
        (endDate ?? uiState.endDate) >= (startDate ?? uiState.startDate)
    }
    
    private func validateMaxParticipants(_ maxParticipants: String?) -> Bool {
        (maxParticipants ?? uiState.maxParticipants).isNotBlank()
    }
    
    private func initCurrentUser() {
        cancellable = userRepository.user.first().sink { [weak self] user in
            self?.uiState.user = user
            self?.uiState.managers = [user]
        }
    }
    
    private func initUsers() {
        Task { @MainActor [weak self] in
            let users = await self?.getUsersUseCase.execute().missionManagerSorting()
            if let users {
                self?.uiState.users = users
                self?.defaultUsers = users
            }
        }
    }
    
    struct CreateMissionUiState {
        fileprivate(set) var user: User?
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
        fileprivate(set) var createEnabled: Bool = false
    }
}
