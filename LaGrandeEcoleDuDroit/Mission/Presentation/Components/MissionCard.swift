import SwiftUI

struct MissionCard: View {
    let mission: Mission
    let onClick: () -> Void
    let onOptionsClick: () -> Void
    
    var body: some View {
        switch mission.state {
            case .published:
                Button(action: onClick) {
                    DefaultMissionCard(
                        mission: mission,
                        onOptionsClick: onOptionsClick
                    )
                }
                .buttonStyle(ClickStyle())
                .clipShape(ShapeDefaults.medium)
                
            case .error:
                Button(action: onClick) {
                    ErrorMissionCard(mission: mission)
                }
                .buttonStyle(ClickStyle())
                .clipShape(ShapeDefaults.medium)
                
            default:
                Button(action: onClick) {
                    PublishingMissionCard(
                        mission: mission,
                        onOptionsClick: onOptionsClick
                    )
                }
                .buttonStyle(ClickStyle())
                .clipShape(ShapeDefaults.medium)
        }
    }
}

private struct DefaultMissionCard: View {
    let mission: Mission
    let onOptionsClick: () -> Void
    
    var body: some View {
        VStack(spacing: Dimens.smallMediumPadding + 2) {
            ZStack {
                MissionImage(missionState: mission.state)
                    .frame(height: 180)
                    .clipped()
                
                OptionsButton(action: onOptionsClick)
                    .padding()
                    .padding(Dimens.extraSmallPadding)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: .infinity,
                        alignment: .topTrailing
                    )
                    .buttonStyle(.borderless)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            
            VStack(alignment: .leading, spacing: Dimens.mediumPadding) {
                CardHeader(mission: mission)
                
                CardContent(description: mission.description)
                
                if mission.schoolLevelRestricted {
                    CardFooter(schoolLevels: mission.schoolLevels)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .overlay(
            ShapeDefaults.medium
                .stroke(.outlineVariant, lineWidth: 2)
        )
        .contentShape(ShapeDefaults.medium)
        .clipShape(ShapeDefaults.medium)
    }
}

private struct PublishingMissionCard: View {
    let mission: Mission
    let onOptionsClick: () -> Void
    
    var body: some View {
        DefaultMissionCard(
            mission: mission,
            onOptionsClick: onOptionsClick
        )
        .opacity(0.5)
    }
}

private struct ErrorMissionCard: View {
    let mission: Mission
    
    var body: some View {
        VStack(spacing: Dimens.smallMediumPadding + 2) {
            ZStack {
                MissionImage(missionState: mission.state)
                    .frame(height: 180)
                    .clipped()
                
                ErrorBanner()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            
            VStack(alignment: .leading, spacing: Dimens.mediumPadding) {
                CardHeader(mission: mission)
                
                CardContent(description: mission.description)
                
                if mission.schoolLevelRestricted {
                    CardFooter(schoolLevels: mission.schoolLevels)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .overlay(
            ShapeDefaults.medium
                .stroke(.outlineVariant, lineWidth: 2)
        )
        .contentShape(ShapeDefaults.medium)
        .clipShape(ShapeDefaults.medium)
    }
}

private struct CardHeader: View {
    let mission: Mission
    
    var body: some View {
        VStack(alignment: .leading, spacing: Dimens.smallPadding) {
            HStack(alignment: .top, spacing: Dimens.smallPadding) {
                Text(mission.title)
                    .font(.titleLarge)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextIcon(
                    icon: Image(systemName: "person.2"),
                    text: stringResource(
                        .participantNumber,
                        mission.participants.count,
                        mission.maxParticipants
                    ),
                    spacing: Dimens.smallPadding
                )
                .font(.bodyMedium)
                .padding(.top, Dimens.extraSmallPadding)
            }
            
            Text(MissionPresentationUtils.formatDate(startDate: mission.startDate, endDate: mission.endDate))
                .foregroundStyle(.informationText)
                .font(.bodyMedium)
        }
    }
}

private struct CardContent: View {
    let description: String
    
    var body: some View {
        Text(description)
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(3)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct CardFooter: View {
    let schoolLevels: [SchoolLevel]
    
    var body: some View {
        Text(MissionPresentationUtils.formatSchoolLevels(schoolLevels: schoolLevels))
            .font(.caption)
            .fontWeight(.semibold)
    }
}

private struct ErrorBanner: View {
    var body: some View {
        TextIcon(
            icon: Image(systemName: "exclamationmark.circle"),
            text: stringResource(.sendingError)
        )
        .font(.callout)
        .foregroundStyle(.error)
        .padding(.vertical, Dimens.smallMediumPadding)
        .padding(.horizontal, Dimens.mediumPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.appBackground.opacity(0.8))
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Dimens.mediumPadding) {
            DefaultMissionCard(
                mission: missionFixture,
                onOptionsClick: {}
            )
            
            PublishingMissionCard(
                mission: missionFixture.copy {
                    $0.state = .publishing()
                },
                onOptionsClick: {}
            )
            
            ErrorMissionCard(
                mission: missionFixture.copy {
                    $0.state = .error()
                }
            )
        }
        .padding()
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
