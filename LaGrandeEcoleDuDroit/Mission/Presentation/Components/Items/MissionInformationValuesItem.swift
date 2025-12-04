import SwiftUI

struct MissionInformationValuesItem: View {
    let mission: Mission
    
    var body: some View {
        let missionInformationValues = missionInformationValues(mission: mission)
        
        VStack(alignment: .leading, spacing: Dimens.mediumLargePadding) {
            ForEach(missionInformationValues, id: \.self) { value in
                TextIcon(
                    icon: Image(systemName: value.imageSystemName),
                    text: value.text
                )
            }
        }
    }
    
    private func missionInformationValues(mission: Mission) -> [MissionInformationValue] {
        let schoolLevelText = if mission.schoolLevelRestricted {
            MissionPresentationUtils.formatSchoolLevels(schoolLevels: mission.schoolLevels)
        } else {
            stringResource(.everyone)
        }
        
        let remainingSpotText = if mission.full {
            stringResource(.full)
        } else {
            stringResource(
                .remainingSpots,
                MissionPresentationUtils.formatRemainingParticipants(
                    participantsCout: mission.participants.count,
                    maxParticipants: mission.maxParticipants
                )
            )
        }
        
        var missionInformationValues : [MissionInformationValue] = [
            .init(
                imageSystemName: "calendar",
                text: MissionPresentationUtils.formatDate(startDate: mission.startDate, endDate: mission.endDate)
            ),
            .init(
                imageSystemName: "graduationcap",
                text: schoolLevelText
            ),
            .init(
                imageSystemName: "person.2",
                text: remainingSpotText
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
