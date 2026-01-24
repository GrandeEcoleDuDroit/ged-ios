import SwiftUI

struct MissionDetailsTitleAndDescriptionSection: View {
    let mission: Mission
    
    var body: some View {
        VStack(alignment: .leading, spacing: DimensResource.mediumPadding) {
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
        VStack(alignment: .leading, spacing: DimensResource.mediumPadding) {
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
    let onSeeAllClick: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DimensResource.smallPadding) {
            HStack {
                SectionTitle(title: stringResource(.managers))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if managers.count > MissionUtilsPresentation.maxUserItemDisplayed {
                    SeeAllUsersButton(
                        userCount: managers.count - MissionUtilsPresentation.maxUserItemDisplayed,
                        action: onSeeAllClick
                    )
                }
            }
            .padding(.horizontal)
            
            LazyVStack(spacing: .zero) {
                ForEach(managers.take(MissionUtilsPresentation.maxUserItemDisplayed)) { manager in
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
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MissionDetailsParticipantSection: View {
    let participants: [User]
    let onParticipantClick: (User) -> Void
    let onSeeAllClick: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: DimensResource.smallPadding) {
            HStack {
                SectionTitle(title: stringResource(.participants))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if participants.count > MissionUtilsPresentation.maxUserItemDisplayed {
                    SeeAllUsersButton(
                        userCount: participants.count - MissionUtilsPresentation.maxUserItemDisplayed,
                        action: onSeeAllClick
                    )
                }
            }
            .padding(.horizontal)
            
            LazyVStack(spacing: .zero) {
                if participants.isEmpty {
                    EmptyText(stringResource(.noParticipant))
                        .font(MissionUtilsPresentation.contentFont)
                } else {
                    ForEach(participants.take(MissionUtilsPresentation.maxUserItemDisplayed)) { participant in
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
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MissionDetailsTaskSection: View {
    let missionTasks: [MissionTask]
    
    var body: some View {
        VStack(alignment: .leading, spacing: DimensResource.smallMediumPadding) {
            SectionTitle(title: stringResource(.tasks))
            
            VStack(spacing: DimensResource.smallPadding) {
                ForEach(missionTasks) { missionTask in
                    HStack(alignment: .top, spacing: DimensResource.smallPadding) {
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

private struct SeeAllUsersButton: View {
    let userCount: Int
    let action: () -> Void
    
    var body: some View {
        Button(
            stringResource(.seeAllUsers, userCount),
            action: action
        )
        .foregroundStyle(.gedPrimary)
        .font(.callout)
    }
}

#Preview("Title and description section") {
    MissionDetailsTitleAndDescriptionSection(mission: missionFixture)
        .padding(.horizontal)
}

#Preview("Information section") {
    MissionDetailsInformationSection(mission: missionFixture)
}

#Preview("Managers section") {
    MissionDetailsManagerSection(
        managers: usersFixture + usersFixture,
        onManagerClick: { _ in },
        onSeeAllClick: {}
    )
}

#Preview("Participants section") {
    MissionDetailsParticipantSection(
        participants: missionFixture.participants,
        onParticipantClick: { _ in },
        onSeeAllClick: {}
    )
}

#Preview("Tasks section") {
    MissionDetailsTaskSection(
        missionTasks: missionFixture.tasks
    )
}
