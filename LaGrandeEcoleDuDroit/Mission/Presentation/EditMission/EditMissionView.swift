import SwiftUI
import PhotosUI

struct EditMissionDestination: View {
    private let onBackClick: () -> Void
    @StateObject private var viewModel: EditMissionViewModel
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    
    init(
        onBackClick: @escaping () -> Void,
        mission: Mission
    ) {
        self.onBackClick = onBackClick
        self._viewModel = StateObject(
            wrappedValue: MissionMainThreadInjector.shared.resolve(EditMissionViewModel.self, arguments: mission)!
        )
    }
    
    var body: some View {
        EditMissionView(
            title: viewModel.uiState.title,
            description: viewModel.uiState.description,
            startDate: viewModel.uiState.startDate,
            endDate: viewModel.uiState.endDate,
            allSchoolLevels: viewModel.uiState.allSchoolLevels,
            schoolLevels: viewModel.uiState.schoolLevels,
            duration: viewModel.uiState.duration,
            maxParticipants: viewModel.uiState.maxParticipants,
            users: viewModel.uiState.users,
            managers: viewModel.uiState.managers,
            userQuery: viewModel.uiState.userQuery,
            missionTasks: viewModel.uiState.missionTasks,
            loading: viewModel.uiState.loading,
            missionState: viewModel.uiState.missionState,
            editEnabled: viewModel.uiState.updateEnabled,
            schoolLevelSupportingText: viewModel.uiState.schoolLevelSupportingText,
            maxParticipantsError: viewModel.uiState.maxParticipantsError,
            onImageChange: viewModel.onImageChange,
            onImageRemove: viewModel.onImageRemove,
            onTitleChange: viewModel.onTitleChange,
            onDescriptionChange: viewModel.onDescriptionChange,
            onStartDateChange: viewModel.onStartDateChange,
            onEndDateChange: viewModel.onEndDateChange,
            onSchoolLevelChange: viewModel.onSchoolLevelChange,
            onMaxParticipantsChange: viewModel.onMaxParticipantsChange,
            onDurationChange: viewModel.onDurationChange,
            onSaveManagersClick: viewModel.onSaveManagers,
            onRemoveManagerClick: viewModel.onRemoveManager,
            onUserQueryChange: viewModel.onUserQueryChange,
            onAddTaskClick: viewModel.onAddMissionTask,
            onEditTaskClick: viewModel.onEditMissionTask,
            onRemoveTaskClick: viewModel.onRemoveMissionTask,
            onSaveMissionClick: viewModel.updateMission
        )
        .onReceive(viewModel.$event) { event in
            if event is SuccessEvent {
                onBackClick()
            } else if case let event as ErrorEvent = event {
                errorMessage = event.message
                showErrorAlert = true
            }
        }
        .alert(
            errorMessage,
            isPresented: $showErrorAlert,
            actions: {
                Button(stringResource(.ok)) {
                    showErrorAlert = false
                }
            }
        )
    }
}

private struct EditMissionView: View {
    let title: String
    let description: String
    let startDate: Date
    let endDate: Date
    let allSchoolLevels: [SchoolLevel]
    let schoolLevels: [SchoolLevel]
    let duration: String
    let maxParticipants: String
    let users: [User]
    let managers: [User]
    let userQuery: String
    let missionTasks: [MissionTask]
    let loading: Bool
    let missionState: Mission.MissionState
    let editEnabled: Bool
    let schoolLevelSupportingText: String?
    let maxParticipantsError: String?
    
    let onImageChange: () -> Void
    let onImageRemove: () -> Void
    let onTitleChange: (String) -> String
    let onDescriptionChange: (String) -> String
    let onStartDateChange: (Date) -> Void
    let onEndDateChange: (Date) -> Void
    let onSchoolLevelChange: (SchoolLevel) -> Void
    let onMaxParticipantsChange: (String) -> String
    let onDurationChange: (String) -> String
    let onSaveManagersClick: ([User]) -> Void
    let onRemoveManagerClick: (User) -> Void
    let onUserQueryChange: (String) -> Void
    let onAddTaskClick: (String) -> Void
    let onEditTaskClick: (MissionTask) -> Void
    let onRemoveTaskClick: (MissionTask) -> Void
    let onSaveMissionClick: (Data?) -> Void
    
    @State private var imageData: Data?
    @State private var activeSheet: EditMissionViewSheet?
    
    var body: some View {
        MissionForm(
            value: MissionFormValue(
                title: title,
                description: description,
                startDate: startDate,
                endDate: endDate,
                allSchoolLevels: allSchoolLevels,
                schoolLevels: schoolLevels,
                duration: duration,
                maxParticipants: maxParticipants,
                managers: managers,
                missionTasks: missionTasks,
                missionState: missionState,
                schoolLevelSupportingText: schoolLevelSupportingText,
                maxParticipantsError: maxParticipantsError
            ),
            imageData: $imageData,
            onImageChange: { onImageChange() },
            onImageRemove: { onImageRemove() },
            onTitleChange: onTitleChange,
            onDescriptionChange: onDescriptionChange,
            onStartDateChange: onStartDateChange,
            onEndDateChange: onEndDateChange,
            onSchoolLevelChange: onSchoolLevelChange,
            onMaxParticipantsChange: onMaxParticipantsChange,
            onDurationChange: onDurationChange,
            onShowManagerListClick: { activeSheet = .selectManager },
            onRemoveManagerClick: onRemoveManagerClick,
            onAddTaskClick: { activeSheet = .addTask },
            onEditTaskClick: { activeSheet = .editTask($0) },
            onRemoveTaskClick: onRemoveTaskClick
        )
        .loading(loading)
        .navigationTitle(stringResource(.editMission))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { onSaveMissionClick(imageData) }) {
                    if !editEnabled {
                        Text(stringResource(.save))
                    } else {
                        Text(stringResource(.save))
                            .foregroundStyle(.gedPrimary)
                    }
                }
                .fontWeight(.semibold)
                .disabled(!editEnabled)
            }
        }
        .sheet(item: $activeSheet) {
            switch $0 {
                case .addTask:
                    AddMissionTaskSheet(
                        onAddTaskClick: {
                            activeSheet = nil
                            onAddTaskClick($0)
                        },
                        onCancelClick: { activeSheet = nil }
                    )
                    .presentationDetents([.medium])
                    
                case let .editTask(missionTask):
                    EditMissionTaskSheet(
                        missionTask: missionTask,
                        onEditTaskClick: {
                            activeSheet = nil
                            onEditTaskClick($0)
                        },
                        onCancelClick: { activeSheet = nil }
                    )
                    .presentationDetents([.medium])
                    
                case .selectManager:
                    SelectManagerSheet(
                        users: users,
                        selectedManagers: managers.toSet(),
                        userQuery: userQuery,
                        onUserQueryChange: onUserQueryChange,
                        onSaveManagersClick: {
                            activeSheet = nil
                            onSaveManagersClick($0)
                        },
                        onCancelClick: { activeSheet = nil }
                    )
            }
        }
    }
}

enum EditMissionViewSheet: Identifiable {
    case addTask
    case editTask(MissionTask)
    case selectManager

    var id: Int {
        switch self {
            case .addTask: 0
            case .editTask: 1
            case .selectManager: 2
        }
    }
}

#Preview {
    let mission = missionFixture
    
    NavigationStack {
        EditMissionView(
            title: mission.title,
            description: mission.description,
            startDate: mission.startDate,
            endDate: mission.endDate,
            allSchoolLevels: SchoolLevel.allCases,
            schoolLevels: mission.schoolLevels,
            duration: mission.duration.orEmpty(),
            maxParticipants: mission.maxParticipants.description,
            users: usersFixture,
            managers: mission.managers,
            userQuery: "",
            missionTasks: mission.tasks,
            loading: false,
            missionState: .published(imageUrl: "https://cdn.britannica.com/16/234216-050-C66F8665/beagle-hound-dog.jpg"),
            editEnabled: false,
            schoolLevelSupportingText: nil,
            maxParticipantsError: nil,
            onImageChange: {},
            onImageRemove: {},
            onTitleChange: { _ in "" },
            onDescriptionChange: { _ in "" },
            onStartDateChange: { _ in },
            onEndDateChange: { _ in },
            onSchoolLevelChange: { _ in },
            onMaxParticipantsChange: { _ in "" },
            onDurationChange: { _ in "" },
            onSaveManagersClick: { _ in },
            onRemoveManagerClick: { _ in },
            onUserQueryChange: { _ in },
            onAddTaskClick: { _ in },
            onEditTaskClick: { _ in },
            onRemoveTaskClick: { _ in },
            onSaveMissionClick: { _ in }
        )
        .background(.appBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
