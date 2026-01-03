import SwiftUI

struct MissionDetailsTitleAndDescriptionSection: View {
    let mission: Mission
    
    var body: some View {
        VStack(alignment: .leading, spacing: Dimens.mediumPadding) {
            Text(mission.title)
                .font(MissionUtilsPresentation.titleFont)
                .fontWeight(.semibold)
                .lineSpacing(3)
                .multilineTextAlignment(.leading)
            
            Text(mission.description)
                .font(MissionUtilsPresentation.contentFont)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MissionDetailsInformationSection: View {
    let mission: Mission
    
    var body: some View {
        VStack(alignment: .leading, spacing: Dimens.mediumPadding) {
            SectionTitle(title: stringResource(.information))
            
            MissionInformationValuesItem(mission: mission)
                .font(MissionUtilsPresentation.contentFont)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MissionDetailsManagerSection: View {
    let managers: [User]
    let onManagerClick: (User) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Dimens.smallPadding) {
            SectionTitle(title: stringResource(.managers))
                .padding(.horizontal)
            
            ScrollView {
                LazyVStack(spacing: .zero) {
                    ForEach(managers) { manager in
                        Button(action: { onManagerClick(manager) }) {
                            MissionUserItem(
                                user: manager,
                                imageScale: 0.4,
                                showAdminIndicator: false
                            )
                            .font(MissionUtilsPresentation.contentFont)
                            .frame(maxWidth: .infinity)
                            .contentShape(.rect)
                        }
                        .buttonStyle(ClickStyle())
                    }
                }
            }
            .frame(maxHeight: 200)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MissionDetailsParticipantSection: View {
    let participants: [User]
    let onParticipantClick: (User) -> Void
    let onLongParticipantClick: (User) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: Dimens.smallPadding) {
            SectionTitle(title: stringResource(.participants))
                .padding(.horizontal)
            
            ScrollView {
                LazyVStack(spacing: .zero) {
                    if participants.isEmpty {
                        EmptyText(stringResource(.noParticipant))
                            .font(MissionUtilsPresentation.contentFont)
                    } else {
                        ForEach(participants) { participant in
                            Button(action: { onParticipantClick(participant) }) {
                                MissionUserItem(
                                    user: participant,
                                    imageScale: 0.4,
                                    showAdminIndicator: false
                                )
                                .font(MissionUtilsPresentation.contentFont)
                                .frame(maxWidth: .infinity)
                                .contentShape(.rect)
                            }
                            .buttonStyle(ClickStyle())
                            .simultaneousGesture(
                                LongPressGesture()
                                    .onEnded { _ in
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        onLongParticipantClick(participant)
                                    }
                            )
                        }
                    }
                }
            }
            .frame(maxHeight: 200)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MissionDetailsTaskSection: View {
    let missionTasks: [MissionTask]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Dimens.smallMediumPadding) {
            SectionTitle(title: stringResource(.tasks))
            
            VStack(spacing: Dimens.smallPadding) {
                ForEach(missionTasks) { missionTask in
                    HStack(alignment: .top, spacing: Dimens.smallPadding) {
                        Text("\u{2022}")
                            .font(.system(size: 24))
                            .padding(.top, -6)
                        
                        Text(missionTask.value)
                            .font(MissionUtilsPresentation.contentFont)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Title and description section") {
    MissionDetailsTitleAndDescriptionSection(mission: missionFixture)
}

#Preview("Information section") {
    MissionDetailsInformationSection(mission: missionFixture)
}

#Preview("Managers section") {
    MissionDetailsManagerSection(
        managers: missionFixture.managers,
        onManagerClick: { _ in }
    )
}

#Preview("Participants section") {
    MissionDetailsParticipantSection(
        participants: missionFixture.participants,
        onParticipantClick: { _ in },
        onLongParticipantClick: { _ in }
    )
}

#Preview("Tasks section") {
    MissionDetailsTaskSection(
        missionTasks: missionFixture.tasks
    )
}
