import SwiftUI

struct MissionInformationValuesItem: View {
    let mission: Mission
    
    var body: some View {
        let missionInformationValues = missionInformationValues(mission: mission)
        
        VStack(alignment: .leading, spacing: DimensResource.mediumLargePadding) {
            ForEach(missionInformationValues, id: \.self) { value in
                TextIcon(
                    icon: Image(systemName: value.imageSystemName),
                    text: value.text
                )
            }
        }
    }
    
    private func missionInformationValues(mission: Mission) -> [MissionInformationValue] {
        var missionInformationValues : [MissionInformationValue] = [
            .init(
                imageSystemName: "calendar",
                text: MissionUtilsPresentation.formatDate(startDate: mission.startDate, endDate: mission.endDate)
            ),
            .init(
                imageSystemName: "graduationcap",
                text: MissionUtilsPresentation.formatSchoolLevels(schoolLevels: mission.schoolLevels)
            ),
            .init(
                imageSystemName: "person.2",
                text: MissionUtilsPresentation.formatParticipantNumber(
                    participantsCount: mission.participants.count,
                    maxParticipants: mission.maxParticipants
                )
            )
        ]
        
        if let duration = mission.duration {
            missionInformationValues.append(
                .init(imageSystemName: "clock", text: duration)
            )
        }
        
        return missionInformationValues
    }
}

private struct MissionInformationValue: Hashable {
    let imageSystemName: String
    let text: String
}

#Preview {
    MissionInformationValuesItem(mission: missionFixture)
}
