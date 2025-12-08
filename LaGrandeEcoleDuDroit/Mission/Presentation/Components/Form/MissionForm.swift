import SwiftUI

struct MissionForm: View {
    let value: MissionFormValue
    @Binding var imageData: Data?
    let onImageChange: () -> Void
    let onImageRemove: () -> Void
    let onTitleChange: (String) -> String
    let onDescriptionChange: (String) -> String
    let onStartDateChange: (Date) -> Void
    let onEndDateChange: (Date) -> Void
    let onSchoolLevelChange: (SchoolLevel) -> Void
    let onMaxParticipantsChange: (String) -> String
    let onDurationChange: (String) -> String
    let onShowManagerListClick: () -> Void
    let onRemoveManagerClick: (User) -> Void
    let onAddTaskClick: () -> Void
    let onEditTaskClick: (MissionTask) -> Void
    let onRemoveTaskClick: (MissionTask) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: Dimens.mediumPadding) {
                MissionFormImageSection(
                    imageData: $imageData,
                    missionState: value.missionState,
                    onImageChange: onImageChange,
                    onImageRemove: onImageRemove
                )
                
                MissionFormTitleDescriptionSection(
                    title: value.title,
                    description: value.description,
                    onTitleChange: onTitleChange,
                    onDescriptionChange: onDescriptionChange
                )
                .padding(.horizontal)
                
                HorizontalDivider()
                    .padding(.horizontal)
                
                MissionFormInformationSection(
                    startDate: value.startDate,
                    endDate: value.endDate,
                    schoolLevels: value.schoolLevels,
                    allSchoolLevels: value.allSchoolLevels,
                    maxParticipants: value.maxParticipants,
                    duration: value.duration,
                    schoolLevelSupportingText: value.schoolLevelSupportingText,
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
                    managers: value.managers,
                    onShowManagerListClick: onShowManagerListClick,
                    onRemoveManagerClick: onRemoveManagerClick
                )
                
                HorizontalDivider()
                    .padding(.horizontal)

                MissionFormTaskSection(
                    missionTasks: value.missionTasks,
                    onTaskClick: onEditTaskClick,
                    onAddTaskClick: onAddTaskClick,
                    onRemoveTaskClick: onRemoveTaskClick
                )
            }
        }
        .scrollIndicators(.hidden)
    }
}

struct MissionFormValue {
    let title: String
    let description: String
    let startDate: Date
    let endDate: Date
    let allSchoolLevels: [SchoolLevel]
    let schoolLevels: [SchoolLevel]
    let duration: String
    let maxParticipants: String
    let managers: [User]
    let missionTasks: [MissionTask]
    let missionState: Mission.MissionState
    let schoolLevelSupportingText: String?
        
    init(
        title: String,
        description: String,
        startDate: Date,
        endDate: Date,
        allSchoolLevels: [SchoolLevel],
        schoolLevels: [SchoolLevel],
        duration: String,
        maxParticipants: String,
        managers: [User],
        missionTasks: [MissionTask],
        missionState: Mission.MissionState,
        schoolLevelSupportingText: String? = nil
    ) {
        self.title = title
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.allSchoolLevels = allSchoolLevels
        self.schoolLevels = schoolLevels
        self.duration = duration
        self.maxParticipants = maxParticipants
        self.managers = managers
        self.missionTasks = missionTasks
        self.missionState = missionState
        self.schoolLevelSupportingText = schoolLevelSupportingText
    }
}

#Preview {
    MissionForm(
        value: MissionFormValue(
            title: "",
            description: "",
            startDate: Date(),
            endDate: Date(),
            allSchoolLevels: SchoolLevel.allCases,
            schoolLevels: [],
            duration: "",
            maxParticipants: "",
            managers: [userFixture],
            missionTasks: missionTasksFixture,
            missionState: .draft
        ),
        imageData: .constant(nil),
        onImageChange: {},
        onImageRemove: {},
        onTitleChange: { _ in "" },
        onDescriptionChange: { _ in "" },
        onStartDateChange: { _ in },
        onEndDateChange: { _ in },
        onSchoolLevelChange: { _ in },
        onMaxParticipantsChange: { _ in "" },
        onDurationChange: { _ in "" },
        onShowManagerListClick: {},
        onRemoveManagerClick: { _ in },
        onAddTaskClick: {},
        onEditTaskClick: { _ in },
        onRemoveTaskClick: { _ in }
    )
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
 
