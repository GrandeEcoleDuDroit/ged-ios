import SwiftUI

struct MissionForm: View {
    @Binding var imageData: Data?
    @Binding var title: String
    @Binding var description: String
    let startDate: Date
    let endDate: Date
    let selectedSchoolLevels: [SchoolLevel]
    let allSchoolLevels: [SchoolLevel]
    @Binding var maxParticipants: String
    @Binding var duration: String
    let managers: [User]
    let missionTasks: [MissionTask]
    let missionState: Mission.MissionState
    var schoolLevelSupportingText: String? = nil
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

    var body: some View {
        ScrollView {
            VStack(spacing: Dimens.mediumPadding) {
                MissionFormImageSection(
                    imageData: $imageData,
                    missionState: missionState,
                    onImageChange: onImageChange,
                    onImageRemove: onImageRemove
                )
                
                MissionFormTitleDescriptionSection(
                    title: $title,
                    description: $description,
                    onTitleChange: onTitleChange,
                    onDescriptionChange: onDescriptionChange
                )
                .padding(.horizontal)
                
                HorizontalDivider()
                    .padding(.horizontal)
                
                MissionFormInformationSection(
                    startDate: startDate,
                    endDate: endDate,
                    selectedSchoolLevels: selectedSchoolLevels,
                    allSchoolLevels: allSchoolLevels,
                    maxParticipants: $maxParticipants,
                    duration: $duration,
                    schoolLevelSupportingText: schoolLevelSupportingText,
                    maxParticipantsError: maxParticipantsError,
                    onStartDateChange: onStartDateChange,
                    onEndDateChange: onEndDateChange,
                    onSchoolLevelChange: onSchoolLevelChange,
                    onMaxParticipantsChange: onMaxParticipantsChange,
                    onDurationChange: onDurationChange
                )
                .padding(.horizontal)
                
                HorizontalDivider()
                    .padding(.horizontal)
                
                MissionFormManagerSection(
                    managers: managers,
                    onAddManagerClick: onAddManagerClick,
                    onRemoveManagerClick: onRemoveManagerClick
                )
                
                HorizontalDivider()
                    .padding(.horizontal)
                
                MissionFormTaskSection(
                    missionTasks: missionTasks,
                    onTaskClick: onEditTaskClick,
                    onAddTaskClick: onAddTaskClick,
                    onRemoveTaskClick: onRemoveTaskClick
                )
            }
        }
        .scrollIndicators(.hidden)
        .scrollDismissesKeyboard(.interactively)
    }
}

#Preview {
    MissionForm(
        imageData: .constant(nil),
        title: .constant(""),
        description: .constant(""),
        startDate: Date(),
        endDate: Date(),
        selectedSchoolLevels: [],
        allSchoolLevels: SchoolLevel.all,
        maxParticipants: .constant(""),
        duration: .constant(""),
        managers: [userFixture],
        missionTasks: missionTasksFixture,
        missionState: .draft,
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
        onRemoveTaskClick: { _ in }
    )
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
 
