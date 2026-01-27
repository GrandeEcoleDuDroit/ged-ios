import SwiftUI
import PhotosUI

struct EditMissionDestination: View {
    private let onBackClick: () -> Void
    
    @StateObject private var viewModel: EditMissionViewModel
    @State private var showErrorAlert: Bool = false
    @State private var showImageErrorAlert: Bool = false
    @State private var errorTitle: String = ""
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
        NavigationStack {
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
                onUpdateManagersClick: viewModel.onUpdateManagers,
                onRemoveManagerClick: viewModel.onRemoveManager,
                onAddMissionTaskClick: viewModel.onAddMissionTask,
                onUpdateMissionTaskClick: viewModel.onUpdateMissionTask,
                onRemoveMissionTaskClick: viewModel.onRemoveMissionTask,
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
        }
    }
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
    let onUpdateManagersClick: ([User]) -> Void
    let onRemoveManagerClick: (User) -> Void
    let onAddMissionTaskClick: (String) -> Void
    let onUpdateMissionTaskClick: (MissionTask) -> Void
    let onRemoveMissionTaskClick: (MissionTask) -> Void
    let onSaveMissionClick: (Data?) -> Void
    let onBackClick: () -> Void
    
    @State private var imageData: Data?
    @State private var showImageErrorAlert: Bool = false
    @State private var activeSheet: EditMissionViewSheet?
    
    var body: some View {
        MissionForm(
            imageData: imageData,
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
            onImageChange: {
                if $0.count < CommonUtilsPresentation.maxImageFileSize {
                    imageData = $0
                    onImageChange()
                } else {
                    showImageErrorAlert = true
                }
            },
            onImageRemove: onImageRemove,
            onTitleChange: onTitleChange,
            onDescriptionChange: onDescriptionChange,
            onStartDateChange: onStartDateChange,
            onEndDateChange: onEndDateChange,
            onSchoolLevelChange: onSchoolLevelChange,
            onMaxParticipantsChange: onMaxParticipantsChange,
            onDurationChange: onDurationChange,
            onAddManagerClick: { activeSheet = .selectManager },
            onRemoveManagerClick: onRemoveManagerClick,
            onAddTaskClick: { activeSheet = .addMissionTask },
            onEditTaskClick: { activeSheet = .editMissionTask($0) },
            onRemoveTaskClick: onRemoveMissionTaskClick
        )
        .loading(loading)
        .alertImageTooLargeError(isPresented: $showImageErrorAlert)
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
        .sheet(item: $activeSheet) {
            switch $0 {
                case .selectManager:
                    SelectManagerDestination(
                        users: users,
                        selectedManagers: managers.toSet(),
                        onSaveManagersClick: {
                            activeSheet = nil
                            onUpdateManagersClick($0)
                        },
                        onCancelClick: {
                            activeSheet = nil
                        }
                    )
                    
                case .addMissionTask:
                    AddMissionTaskView(
                        onAddTaskClick: {
                            activeSheet = nil
                            onAddMissionTaskClick($0)
                        },
                        onCancelClick: {
                            activeSheet = nil
                        }
                    )
                    
                case let .editMissionTask(missionTask):
                    EditMissionTaskView(
                        missionTask: missionTask,
                        onSaveTaskClick: {
                            activeSheet = nil
                            onUpdateMissionTaskClick($0)
                        },
                        onCancelClick: {
                            activeSheet = nil
                        }
                    )
            }
        }
    }
}

private enum EditMissionViewSheet: Identifiable {
    case selectManager
    case addMissionTask
    case editMissionTask(MissionTask)
    
    var id: Int {
        switch self {
            case .selectManager: 0
            case .addMissionTask: 1
            case .editMissionTask: 2
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
            onUpdateManagersClick: { _ in },
            onRemoveManagerClick: { _ in },
            onAddMissionTaskClick: { _ in },
            onUpdateMissionTaskClick: { _ in },
            onRemoveMissionTaskClick: { _ in },
            onSaveMissionClick: { _ in },
            onBackClick: {}
        )
        .background(.appBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
