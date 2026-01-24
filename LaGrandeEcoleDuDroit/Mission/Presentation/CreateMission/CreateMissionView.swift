import SwiftUI
import PhotosUI

struct CreateMissionDestination: View {
    let onBackClick: () -> Void
    
    @StateObject private var viewModel = MissionMainThreadInjector.shared.resolve(CreateMissionViewModel.self)
    @State private var showImageErrorAlert: Bool = false
    @State private var errorTitle: String = ""
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationStack {
            CreateMissionView(
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
                onUpdateManagersClick: viewModel.onUpdateManagers,
                onRemoveManagerClick: viewModel.onRemoveManager,
                onAddMissionTaskClick: viewModel.onAddMissionTask,
                onUpdateMissionTaskClick: viewModel.onUpdateMissionTask,
                onRemoveMissionTaskClick: viewModel.onRemoveMissionTask,
                onCreateMissionClick: viewModel.createMission,
                onBackClick: onBackClick
            )
            .alert(
                errorTitle,
                isPresented: $showImageErrorAlert,
                actions: {
                    Button(stringResource(.ok)) {
                        showImageErrorAlert = false
                    }
                },
                message: {
                    Text(errorMessage)
                }
            )
            .onReceive(viewModel.$event) { event in
                if event is SuccessEvent {
                    onBackClick()
                }
            }
        }
    }
}

private struct CreateMissionView: View {
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
    let onUpdateManagersClick: ([User]) -> Void
    let onRemoveManagerClick: (User) -> Void
    let onAddMissionTaskClick: (String) -> Void
    let onUpdateMissionTaskClick: (MissionTask) -> Void
    let onRemoveMissionTaskClick: (MissionTask) -> Void
    let onCreateMissionClick: (Data?) -> Void
    let onBackClick: () -> Void
    
    @State private var imageData: Data?
    @State private var showImageErrorAlert: Bool = false
    @State private var activeSheet: CrateMissionViewSheet?

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
            maxParticipantsError: maxParticipantsError,
            onImageChange: {
                if $0.count < CommonUtilsPresentation.maxImageFileSize {
                    imageData = $0
                } else {
                    showImageErrorAlert = true
                }
            },
            onImageRemove: { imageData = nil },
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
                Button(
                    action: {
                        if let imageData, let compressImageData = UIImage(data: imageData)?.jpegData(compressionQuality: 0.6) {
                            onCreateMissionClick(compressImageData)
                        } else {
                            onCreateMissionClick(nil)
                        }
                    }
                ) {
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
        .alertImageTooLargeError(isPresented: $showImageErrorAlert)
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

private enum CrateMissionViewSheet: Identifiable {
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
    NavigationStack {
        CreateMissionView(
            title: .constant(""),
            description: .constant(""),
            startDate: Date(),
            endDate: Date(),
            selectedSchoolLevels: [],
            allSchoolLevels: SchoolLevel.all,
            maxParticipants: .constant(""),
            duration: .constant(""),
            users: usersFixture,
            managers: [userFixture],
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
            onUpdateManagersClick: { _ in },
            onRemoveManagerClick: { _ in },
            onAddMissionTaskClick: { _ in },
            onUpdateMissionTaskClick: { _ in },
            onRemoveMissionTaskClick: { _ in },
            onCreateMissionClick: { _ in },
            onBackClick: {}
        )
        .background(.appBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
