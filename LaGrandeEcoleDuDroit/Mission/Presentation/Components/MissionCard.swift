import SwiftUI

struct MissionCard: View {
    let mission: Mission
    let onClick: () -> Void
    let onOptionClick: () -> Void
    
    var body: some View {
        switch mission.state {
            case .published:
                Clickable(action: onClick) {
                    DefaultMissionCard(
                        mission: mission,
                        onOptionClick: onOptionClick
                    )
                }
                .clipShape(ShapeDefaults.medium)
                
            case .error:
                Clickable(action: onClick) {
                    ErrorMissionCard(mission: mission)
                }
                .clipShape(ShapeDefaults.medium)
                
            default:
                Clickable(action: onClick) {
                    PublishingMissionCard(
                        mission: mission,
                        onOptionClick: onOptionClick
                    )
                }
                .clipShape(ShapeDefaults.medium)
        }
    }
}

private struct DefaultMissionCard: View {
    let mission: Mission
    let onOptionClick: () -> Void
    
    var body: some View {
        VStack(spacing: Dimens.smallMediumPadding + 2) {
            ZStack {
                MissionImage(missionState: mission.state)
                    .frame(height: 180)
                    .clipped()
                
                OptionButton(action: onOptionClick)
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
    let onOptionClick: () -> Void
    
    var body: some View {
        DefaultMissionCard(
            mission: mission,
            onOptionClick: onOptionClick
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
                    icon: { Image(systemName: "person.2") },
                    text: {
                        Text(
                            stringResource(
                                .participantNumber,
                                mission.participants.count,
                                mission.maxParticipants
                            )
                        )
                    }
                )
                .font(.bodyMedium)
                .padding(.top, Dimens.extraSmallPadding)
            }
            
            Text(MissionFormatter.formatDate(startDate: mission.startDate, endDate: mission.endDate))
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
        Text(MissionFormatter.formatSchoolLevels(schoolLevels: schoolLevels))
            .font(.caption)
            .fontWeight(.semibold)
    }
}

private struct ErrorBanner: View {
    var body: some View {
        TextIcon(
            icon: {
                Image(systemName: "exclamationmark.circle")
            },
            text: {
                Text(stringResource(.sendingError))
            }
        )
        .font(.callout)
        .foregroundStyle(.error)
        .padding(.vertical, Dimens.smallMediumPadding)
        .padding(.horizontal, Dimens.mediumPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.background.opacity(0.8))
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Dimens.mediumPadding) {
            DefaultMissionCard(
                mission: missionFixture,
                onOptionClick: {}
            )
            
            PublishingMissionCard(
                mission: missionFixture.copy {
                    $0.state = .publishing()
                },
                onOptionClick: {}
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
