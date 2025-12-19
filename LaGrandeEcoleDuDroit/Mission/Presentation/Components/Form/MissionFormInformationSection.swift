import SwiftUI

struct MissionFormInformationSection: View {
    let startDate: Date
    let endDate: Date
    let schoolLevels: [SchoolLevel]
    let allSchoolLevels: [SchoolLevel]
    @Binding var maxParticipants: String
    @Binding var duration: String
    let schoolLevelSupportingText: String?
    let maxParticipantsError: String?
    
    let onStartDateChange: (Date) -> Void
    let onEndDateChange: (Date) -> Void
    let onSchoolLevelChange: (SchoolLevel) -> Void
    let onMaxParticipantsChange: (String) -> Void
    let onDurationChange: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Dimens.mediumPadding) {
            SectionTitle(title: stringResource(.information))
            
            OutlinedDatePicker(
                label: stringResource(.missionStartDateField),
                date: startDate,
                onDateChange: onStartDateChange
            )
            
            OutlinedDatePicker(
                label: stringResource(.missionEndDateField),
                date: endDate,
                dateRange: startDate...Date.distantFuture,
                onDateChange: onEndDateChange
            )
            
            OutlinedSchoolLevelPicker(
                schoolLevels: schoolLevels,
                onSchoolLevelChange: onSchoolLevelChange,
                allSchoolLevels: allSchoolLevels,
                supportingText: schoolLevelSupportingText
            )
            
            OutlinedTextField(
                stringResource(.missionMaxParticipantsField),
                text: $maxParticipants,
                errorMessage: maxParticipantsError,
                leadingIcon: Image(systemName: "person.2")
            )
            .keyboardType(.decimalPad)
            .onChange(of: maxParticipants, perform: onMaxParticipantsChange)
            
            OutlinedTextField(
                stringResource(.missionDurationField),
                text: $duration,
                leadingIcon: Image(systemName: "clock")
            )
            .onChange(of: duration, perform: onDurationChange)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct OutlinedDatePicker: View {
    let label: String
    let date: Date
    let dateRange: ClosedRange<Date>?
    let onDateChange: (Date) -> Void
    
    init(
        label: String,
        date: Date,
        dateRange: ClosedRange<Date>? = nil,
        onDateChange: @escaping (Date) -> Void
    ) {
        self.label = label
        self.date = date
        self.dateRange = dateRange
        self.onDateChange = onDateChange
    }
    
    var body: some View {
        HStack {
            HStack(alignment: .center, spacing: Dimens.leadingIconSpacing) {
                Image(systemName: "calendar")
                    .resizable()
                    .scaledToFill()
                    .frame(width: Dimens.inputIconSize, height: Dimens.inputIconSize)
                    .foregroundStyle(.onSurfaceVariant)
                
                Text(label)
            }
                
            Text(date.formatted(date: .abbreviated, time: .omitted))
                .allowsHitTesting(false)
                .background {
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { date },
                            set: onDateChange
                        ),
                        in: dateRange ?? Date.distantPast ... Date.distantFuture,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .scaleEffect(x: 5, y: 1)
                    .colorMultiply(.clear)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .outlined()
    }
}

struct OutlinedSchoolLevelPicker: View {
    let schoolLevels: [SchoolLevel]
    let onSchoolLevelChange: (SchoolLevel) -> Void
    let allSchoolLevels: [SchoolLevel]
    let supportingText: String?
    
    var body: some View {
        MultiSelectionPicker(
            text: formattedSchoolLevel,
            items: allSchoolLevels.map(\.rawValue),
            leadingIcon: Image(systemName: "graduationcap"),
            seletctedItems: schoolLevels.map(\.rawValue),
            onItemSelected: {
                if let schoolLevel = SchoolLevel(rawValue: $0) {
                    onSchoolLevelChange(schoolLevel)
                }
            },
            supportingText: supportingText
        )
    }
    
    var formattedSchoolLevel: String {
        switch schoolLevels {
            case _ where schoolLevels.isEmpty:
                stringResource(.everyone)
                
            case _ where schoolLevels.count == allSchoolLevels.count:
                stringResource(.everyone)
            
            default: MissionUtilsPresentation.formatSchoolLevels(schoolLevels: schoolLevels)
        }
    }
}

#Preview {
    MissionFormInformationSection(
        startDate: Date(),
        endDate: Date(),
        schoolLevels: [],
        allSchoolLevels: SchoolLevel.allCases,
        maxParticipants: .constant(""),
        duration: .constant(""),
        schoolLevelSupportingText: nil,
        maxParticipantsError: nil,
        onStartDateChange: { _ in },
        onEndDateChange: { _ in },
        onSchoolLevelChange: { _ in },
        onMaxParticipantsChange: { _ in },
        onDurationChange: { _ in }
    )
}

#Preview {
    OutlinedDatePicker(
        label: "Date",
        date: Date(),
        onDateChange: { _ in }
    )
    
    OutlinedSchoolLevelPicker(
        schoolLevels: [.ged1, .ged2, .ged3, .ged4],
        onSchoolLevelChange: { _ in },
        allSchoolLevels: SchoolLevel.allCases,
        supportingText: nil
    )
}
