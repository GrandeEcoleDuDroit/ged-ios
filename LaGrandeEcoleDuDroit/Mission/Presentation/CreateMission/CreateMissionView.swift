import SwiftUI
import PhotosUI

struct CreateMissionDestination: View {
    let onBackClick: () -> Void
    
    @StateObject private var viewModel = MissionMainThreadInjector.shared.resolve(CreateMissionViewModel.self)
    
    var body: some View {
        CreateMissionView(
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
            missionState: .draft,
            createEnabled: viewModel.uiState.createEnabled,
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
            onCreateMissionClick: {
                viewModel.createMission(imageData: $0)
                onBackClick()
            }
        )
    }
}

private struct CreateMissionView: View {
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
    let missionState: Mission.MissionState
    let createEnabled: Bool
    
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
    let onCreateMissionClick: (Data?) -> Void
    
    @State private var imageData: Data?
    @State private var activeSheet: CreateMissionViewSheet?

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
                missionState: missionState
            ),
            imageData: $imageData,
            onImageChange: {},
            onImageRemove: {},
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
        .navigationTitle(stringResource(.newMission))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: { onCreateMissionClick(imageData) },
                    label: {
                        if !createEnabled {
                            Text(stringResource(.publish))
                        } else {
                            Text(stringResource(.publish))
                                .foregroundStyle(.gedPrimary)
                        }
                    }
                )
                .fontWeight(.semibold)
                .disabled(!createEnabled)
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

enum CreateMissionViewSheet: Identifiable {
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
    NavigationStack {
        CreateMissionView(
            title: "",
            description: "",
            startDate: Date(),
            endDate: Date(),
            allSchoolLevels: SchoolLevel.allCases,
            schoolLevels: [],
            duration: "",
            maxParticipants: "",
            users: usersFixture,
            managers: [userFixture],
            userQuery: "",
            missionTasks: [missionTaskFixture],
            missionState: .draft,
            createEnabled: false,
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
            onCreateMissionClick: { _ in }
        )
        .background(.appBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
