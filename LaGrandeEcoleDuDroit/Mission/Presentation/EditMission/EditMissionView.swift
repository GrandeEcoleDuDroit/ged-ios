import SwiftUI
import PhotosUI

struct EditMissionDestination: View {
    private let onBackClick: () -> Void
    
    @StateObject private var viewModel: EditMissionViewModel
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var path: [EditMissionSubDestination] = []

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
        NavigationStack(path: $path) {
            EditMissionView(
                title: $viewModel.uiState.title,
                description: $viewModel.uiState.description,
                startDate: viewModel.uiState.startDate,
                endDate: viewModel.uiState.endDate,
                selectedSchoolLevels: viewModel.uiState.selectedSchoolLevels,
                allSchoolLevels: viewModel.uiState.allSchoolLevels,
                maxParticipants: $viewModel.uiState.maxParticipants,
                duration: $viewModel.uiState.duration,
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
                onAddManagerClick: { path.append(.selectManager) },
                onRemoveManagerClick: viewModel.onRemoveManager,
                onAddTaskClick: { path.append(.addMissionTask) },
                onEditTaskClick: { path.append(.editMissionTask($0)) },
                onRemoveTaskClick: viewModel.onRemoveMissionTask,
                onSaveMissionClick: viewModel.updateMission,
                onBackClick: onBackClick
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
            .navigationDestination(for: EditMissionSubDestination.self) { destination in
                switch destination {
                    case .selectManager:
                        SelectManagerView(
                            users: viewModel.uiState.users,
                            selectedManagers: viewModel.uiState.managers.toSet(),
                            onUserQueryChange: viewModel.onUserQueryChange,
                            onSaveManagersClick: {
                                viewModel.onSaveManagers($0)
                                path.removeLast()
                            }
                        )
                        
                    case .addMissionTask:
                        AddMissionTaskView(
                            onAddTaskClick: {
                                viewModel.onAddMissionTask($0)
                                path.removeLast()
                            }
                        )
                        
                    case let .editMissionTask(missionTask):
                        EditMissionTaskView(
                            missionTask: missionTask,
                            onSaveTaskClick: {
                                viewModel.onEditMissionTask($0)
                                path.removeLast()
                            }
                        )
                }
            }
        }
    }
}

private enum EditMissionSubDestination: Hashable {
    case selectManager
    case addMissionTask
    case editMissionTask(MissionTask)
}

private struct EditMissionView: View {
    @Binding var title: String
    @Binding var description: String
    let startDate: Date
    let endDate: Date
    let selectedSchoolLevels: [SchoolLevel]
    let allSchoolLevels: [SchoolLevel]
    @Binding var maxParticipants: String
    @Binding var duration: String
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
    let onTitleChange: (String) -> Void
    let onDescriptionChange: (String) -> Void
    let onStartDateChange: (Date) -> Void
    let onEndDateChange: (Date) -> Void
    let onSchoolLevelChange: (SchoolLevel) -> Void
    let onMaxParticipantsChange: (String) -> Void
    let onDurationChange: (String) -> Void
    let onAddManagerClick: () -> Void
    let onRemoveManagerClick: (User) -> Void
    let onAddTaskClick: () -> Void
    let onEditTaskClick: (MissionTask) -> Void
    let onRemoveTaskClick: (MissionTask) -> Void
    let onSaveMissionClick: (Data?) -> Void
    let onBackClick: () -> Void
    
    @State private var imageData: Data?
    
    var body: some View {
        MissionForm(
            imageData: $imageData,
            title: $title,
            description: $description,
            startDate: startDate,
            endDate: endDate,
            selectedSchoolLevels: selectedSchoolLevels,
            allSchoolLevels: allSchoolLevels,
            maxParticipants: $maxParticipants,
            duration: $duration,
            managers: managers,
            missionTasks: missionTasks,
            missionState: missionState,
            schoolLevelSupportingText: schoolLevelSupportingText,
            maxParticipantsError: maxParticipantsError,
            onImageChange: onImageChange,
            onImageRemove: onImageRemove,
            onTitleChange: onTitleChange,
            onDescriptionChange: onDescriptionChange,
            onStartDateChange: onStartDateChange,
            onEndDateChange: onEndDateChange,
            onSchoolLevelChange: onSchoolLevelChange,
            onMaxParticipantsChange: onMaxParticipantsChange,
            onDurationChange: onDurationChange,
            onAddManagerClick: onAddManagerClick,
            onRemoveManagerClick: onRemoveManagerClick,
            onAddTaskClick: onAddTaskClick,
            onEditTaskClick: onEditTaskClick,
            onRemoveTaskClick: onRemoveTaskClick
        )
        .loading(loading)
        .navigationTitle(stringResource(.editMission))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(
                    stringResource(.cancel),
                    action: onBackClick
                )
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button(action: { onSaveMissionClick(imageData) }) {
                    if editEnabled {
                        Text(stringResource(.save))
                            .foregroundStyle(.gedPrimary)
                    } else {
                        Text(stringResource(.save))
                    }
                }
                .disabled(!editEnabled)
            }
        }
    }
}

#Preview {
    let mission = missionFixture
    
    NavigationStack {
        EditMissionView(
            title: .constant(mission.title),
            description: .constant(mission.description),
            startDate: mission.startDate,
            endDate: mission.endDate,
            selectedSchoolLevels: mission.schoolLevels,
            allSchoolLevels: SchoolLevel.all,
            maxParticipants: .constant(mission.maxParticipants.description),
            duration: .constant(mission.duration.orEmpty()),
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
            onTitleChange: { _ in },
            onDescriptionChange: { _ in },
            onStartDateChange: { _ in },
            onEndDateChange: { _ in },
            onSchoolLevelChange: { _ in },
            onMaxParticipantsChange: { _ in },
            onDurationChange: { _ in },
            onAddManagerClick: {},
            onRemoveManagerClick: { _ in },
            onAddTaskClick: {},
            onEditTaskClick: { _ in },
            onRemoveTaskClick: { _ in },
            onSaveMissionClick: { _ in },
            onBackClick: {}
        )
        .background(.appBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
