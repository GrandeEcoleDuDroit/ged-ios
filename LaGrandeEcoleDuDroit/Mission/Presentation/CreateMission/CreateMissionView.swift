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
            onAddTaskClick: viewModel.onAddTask,
            onEditTaskClick: viewModel.onEditTask,
            onRemoveTaskClick: viewModel.onRemoveTask,
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
    let createEnabled: Bool
    let onTitleChange: (String) -> Void
    let onDescriptionChange: (String) -> Void
    let onStartDateChange: (Date) -> Void
    let onEndDateChange: (Date) -> Void
    let onSchoolLevelChange: (SchoolLevel) -> Void
    let onMaxParticipantsChange: (String) -> Void
    let onDurationChange: (String) -> Void
    let onSaveManagersClick: ([User]) -> Void
    let onRemoveManagerClick: (User) -> Void
    let onUserQueryChange: (String) -> Void
    let onAddTaskClick: (String) -> Void
    let onEditTaskClick: (MissionTask) -> Void
    let onRemoveTaskClick: (MissionTask) -> Void
    let onCreateMissionClick: (Data?) -> Void
    
    @State private var imageData: Data?
    @State private var selectedImage: PhotosPickerItem?
    @State private var showPhotosPicker: Bool = false
    @State private var missionBottomSheetType: MissionBottomSheetType?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        MissionForm(
            value: MissionFormValue(
                imageData: imageData,
                title: title,
                description: description,
                startDate: startDate,
                endDate: endDate,
                allSchoolLevels: allSchoolLevels,
                schoolLevels: schoolLevels,
                duration: duration,
                maxParticipants: maxParticipants,
                managers: managers,
                missionTasks: missionTasks
            ),
            onImageClick: { showPhotosPicker = true },
            onRemoveImageClick: { selectedImage = nil },
            onTitleChange: onTitleChange,
            onDescriptionChange: onDescriptionChange,
            onStartDateChange: onStartDateChange,
            onEndDateChange: onEndDateChange,
            onSchoolLevelChange: onSchoolLevelChange,
            onMaxParticipantsChange: onMaxParticipantsChange,
            onDurationChange: onDurationChange,
            onShowManagerListClick: { missionBottomSheetType = .selectManager },
            onRemoveManagerClick: onRemoveManagerClick,
            onAddTaskClick: { missionBottomSheetType = .addTask },
            onEditTaskClick: { missionBottomSheetType = .editTask(missionTask: $0) },
            onRemoveTaskClick: onRemoveTaskClick
        )
        .photosPicker(
            isPresented: $showPhotosPicker,
            selection: $selectedImage,
            matching: .images
        )
        .task(id: selectedImage) {
            imageData = try? await selectedImage?.loadTransferable(type: Data.self)
        }
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
        .sheet(item: $missionBottomSheetType) { type in
            switch type {
                case .addTask:
                    AddMissionTaskBottomSheet(onAddClick: onAddTaskClick)
                        .presentationDetents([.fraction(0.20), .medium, .large])
                        .presentationContentInteraction(.resizes)
                    
                case let .editTask(missionTask):
                    EditMissionTaskBottomSheet(
                        missionTask: missionTask,
                        onEditClick: onEditTaskClick
                    )
                    .presentationDetents([.fraction(0.20), .medium, .large])
                    .presentationContentInteraction(.resizes)
                    
                case .selectManager:
                    SelectManagerBottomSheet(
                        users: users,
                        selectedManagers: managers.toSet(),
                        userQuery: userQuery,
                        onUserQueryChange: onUserQueryChange,
                        onSaveClick: {
                            onSaveManagersClick($0)
                            dismiss()
                        }
                    )
            }
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
            createEnabled: false,
            onTitleChange: { _ in },
            onDescriptionChange: { _ in },
            onStartDateChange: { _ in },
            onEndDateChange: { _ in },
            onSchoolLevelChange: { _ in },
            onMaxParticipantsChange: { _ in },
            onDurationChange: { _ in },
            onSaveManagersClick: { _ in },
            onRemoveManagerClick: { _ in },
            onUserQueryChange: { _ in },
            onAddTaskClick: { _ in },
            onEditTaskClick: { _ in },
            onRemoveTaskClick: { _ in },
            onCreateMissionClick: { _ in }
        )
        .background(Color.background)
        .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
    }
}
