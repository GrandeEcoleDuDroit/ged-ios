import Foundation
import Combine

class CreateMissionViewModel: ViewModel {
    private let userRepository: UserRepository
    private let createMissionUseCase: CreateMissionUseCase
    private let getUsersUseCase: GetUsersUseCase
    private let generateIdUseCase: GenerateIdUseCase
    
    @Published var uiState = CreateMissionUiState()
    private var defaultUsers: [User] = []
    private var cancellables: Set<AnyCancellable> = []
    
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
        
        createMissionUseCase.execute(mission: mission, imageData: imageData)
    }
    
    func onTitleChange(_ title: String) {
        let truncatedTitle = title.take(MissionConstants.maxTitleLength)
        uiState = uiState.copy {
            $0.title = truncatedTitle
            $0.createEnabled = validateCreate(title: truncatedTitle)
        }
    }
    
    func onDescriptionChange(_ description: String) {
        let truncatedDescription = description.take(MissionConstants.maxDescriptionLength)
        uiState = uiState.copy {
            $0.description = truncatedDescription
            $0.createEnabled = validateCreate(description: truncatedDescription)
        }
    }
    
    func onStartDateChange(_ startDate: Date) {
        uiState = uiState.copy {
            $0.startDate = startDate
            $0.endDate = !validateEndDate(startDate: startDate, endDate: $0.endDate) ? startDate : $0.endDate
        }
    }
    
    func onEndDateChange(_ endDate: Date) {
        uiState = uiState.copy {
            $0.startDate = !validateEndDate(startDate: $0.startDate, endDate: endDate) ? endDate : $0.startDate
            $0.endDate = endDate
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
    
    func onMaxParticipantsChange(_ maxParticipants: String) {
        let value = switch maxParticipants {
            case _ where maxParticipants.isEmpty: ""
            case _ where maxParticipants.toIntOrDefault(-1) > 0: maxParticipants.toInt().description
            default: uiState.maxParticipants
        }
        
        uiState.maxParticipants = value
        uiState.createEnabled = validateCreate(maxParticipants: value)
    }
    
    func onDurationChange(_ duration: String) {
        let truncatedDuration = duration.take(MissionConstants.maxDurationLength)
        uiState.duration = truncatedDuration
    }
    
    func onSaveManagers(_ managers: [User]) {
        uiState.managers = managers
    }
    
    func onRemoveManager(_ manager: User) {
        let managers = uiState.managers
        
        if managers.count > 1 {
            uiState.managers.removeAll { $0.id == manager.id }
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
    
    func onAddTask(_ value: String) {
        let task = MissionTask(id: generateIdUseCase.execute(), value: value)
        uiState.missionTasks.append(task)
    }
    
    func onEditTask(_ missionTask: MissionTask) {
        uiState = uiState.copy { state in
            state.missionTasks = state.missionTasks.replace(
                where: { $0.id == missionTask.id },
                with: missionTask.copy { $0.value = missionTask.value.trim() }
            )
        }
    }
    
    func onRemoveTask(_ missionTask: MissionTask) {
        uiState.missionTasks.removeAll { $0.id == missionTask.id }
    }
    
    private func initCurrentUser() {
        userRepository.user.first().sink { [weak self] user in
            self?.uiState.user = user
            self?.uiState.managers = [user]
        }.store(in: &cancellables)
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
    
    private func initUsers() {
        Task { @MainActor [weak self] in
            let users = await self?.getUsersUseCase.execute().managerSorting()
            if let users {
                self?.uiState.users = users
                self?.defaultUsers = users
            }
        }
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
    
    struct CreateMissionUiState: Copyable {
        fileprivate(set) var user: User?
        fileprivate(set) var title: String = ""
        fileprivate(set) var description: String = ""
        fileprivate(set) var startDate: Date = Date()
        fileprivate(set) var endDate: Date = Date()
        let allSchoolLevels: [SchoolLevel] = SchoolLevel.allCases
        fileprivate(set) var schoolLevels: [SchoolLevel] = []
        fileprivate(set) var duration: String = ""
        fileprivate(set) var managers: [User] = []
        var maxParticipants: String = ""
        fileprivate(set) var missionTasks: [MissionTask] = []
        fileprivate(set) var users: [User] = []
        fileprivate(set) var userQuery: String = ""
        fileprivate(set) var createEnabled: Bool = false
    }
}
