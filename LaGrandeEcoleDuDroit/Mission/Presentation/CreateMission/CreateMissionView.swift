import SwiftUI
import PhotosUI

struct CreateMissionDestination: View {
    let onBackClick: () -> Void
    
    @StateObject private var viewModel = MissionMainThreadInjector.shared.resolve(CreateMissionViewModel.self)
    @State private var path: [CreateMissionSubDestination] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            CreateMissionView(
                title: $viewModel.uiState.title,
                description: $viewModel.uiState.description,
                startDate: viewModel.uiState.startDate,
                endDate: viewModel.uiState.endDate,
                allSchoolLevels: viewModel.uiState.allSchoolLevels,
                schoolLevels: viewModel.uiState.schoolLevels,
                maxParticipants: $viewModel.uiState.maxParticipants,
                duration: $viewModel.uiState.duration,
                users: viewModel.uiState.users,
                managers: viewModel.uiState.managers,
                userQuery: viewModel.uiState.userQuery,
                missionTasks: viewModel.uiState.missionTasks,
                missionState: .draft,
                createEnabled: viewModel.uiState.createEnabled,
                maxParticipantsError: viewModel.uiState.maxParticipantsError,
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
                onCreateMissionClick: viewModel.createMission,
                onBackClick: onBackClick
            )
            .navigationDestination(for: CreateMissionSubDestination.self) { destination in
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
            .onReceive(viewModel.$event) { event in
                if event is SuccessEvent {
                    onBackClick()
                }
            }
        }
    }
}

private enum CreateMissionSubDestination: Hashable {
    case selectManager
    case addMissionTask
    case editMissionTask(MissionTask)
}

private struct CreateMissionView: View {
    @Binding var title: String
    @Binding var description: String
    let startDate: Date
    let endDate: Date
    let allSchoolLevels: [SchoolLevel]
    let schoolLevels: [SchoolLevel]
    @Binding var maxParticipants: String
    @Binding var duration: String
    let users: [User]
    let managers: [User]
    let userQuery: String
    let missionTasks: [MissionTask]
    let missionState: Mission.MissionState
    let createEnabled: Bool
    
    let maxParticipantsError: String?
    
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
    let onCreateMissionClick: (Data?) -> Void
    let onBackClick: () -> Void
    
    @State private var imageData: Data?

    var body: some View {
        MissionForm(
            imageData: $imageData,
            title: $title,
            description: $description,
            startDate: startDate,
            endDate: endDate,
            allSchoolLevels: allSchoolLevels,
            schoolLevels: schoolLevels,
            maxParticipants: $maxParticipants,
            duration: $duration,
            managers: managers,
            missionTasks: missionTasks,
            missionState: missionState,
            maxParticipantsError: maxParticipantsError,
            onImageChange: {},
            onImageRemove: {},
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
        .navigationTitle(stringResource(.newMission))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(
                    stringResource(.cancel),
                    action: onBackClick
                )
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button(action: { onCreateMissionClick(imageData) }) {
                    if createEnabled {
                        Text(stringResource(.publish))
                            .foregroundStyle(.gedPrimary)
                    } else {
                        Text(stringResource(.publish))
                    }
                }
                .disabled(!createEnabled)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateMissionView(
            title: .constant(""),
            description: .constant(""),
            startDate: Date(),
            endDate: Date(),
            allSchoolLevels: SchoolLevel.allCases,
            schoolLevels: [],
            maxParticipants: .constant(""),
            duration: .constant(""),
            users: usersFixture,
            managers: [userFixture],
            userQuery: "",
            missionTasks: [missionTaskFixture],
            missionState: .draft,
            createEnabled: false,
            maxParticipantsError: nil,
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
            onCreateMissionClick: { _ in },
            onBackClick: {}
        )
        .background(.appBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
