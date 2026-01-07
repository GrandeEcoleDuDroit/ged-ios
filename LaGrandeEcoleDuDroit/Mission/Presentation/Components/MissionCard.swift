import SwiftUI

struct MissionCard: View {
    let mission: Mission
    let onOptionsClick: () -> Void
    
    var body: some View {
        switch mission.state {
            case .published:
                if mission.completed {
                    CompletedMissionCard(
                        mission: mission,
                        onOptionsClick: onOptionsClick
                    )
                } else {
                    DefaultMissionCard(
                        mission: mission,
                        onOptionsClick: onOptionsClick
                    )
                }
                
            case .error: ErrorMissionCard(mission: mission)
                
            default:
                PublishingMissionCard(
                    mission: mission,
                    onOptionsClick: onOptionsClick
                )
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
                    .font(.title3)
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
                CardTitle(title: mission.title)
                
                CardSubtitle(mission: mission)
                
                CardBody(description: mission.description)

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
        .clipShape(ShapeDefaults.medium)
    }
}

private struct CompletedMissionCard: View {
    let mission: Mission
    let onOptionsClick: () -> Void
    
    var body: some View {
        VStack(spacing: Dimens.smallMediumPadding + 2) {
            MissionImage(missionState: mission.state)
                .frame(height: 180)
                .clipped()
                .overlay {
                    Text(stringResource(.completed))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .background(.overlayContent.opacity(0.6))
                }
                
            VStack(alignment: .leading, spacing: Dimens.mediumPadding) {
                CardTitle(title: mission.title)
                
                CardSubtitle(mission: mission)
                
                CardBody(description: mission.description)
                
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
                CardTitle(title: mission.title)
                
                CardSubtitle(mission: mission)
                
                CardBody(description: mission.description)
                
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
        .clipShape(ShapeDefaults.medium)
    }
}

private struct CardTitle: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.title3)
            .fontWeight(.semibold)
            .lineSpacing(2)
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(2)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct CardSubtitle: View {
    let mission: Mission
    
    var body: some View {
        VStack(alignment: .leading, spacing: Dimens.smallPadding) {
            TextIcon(
                icon: Image(systemName: "calendar"),
                text: MissionUtilsPresentation.formatDate(startDate: mission.startDate, endDate: mission.endDate),
                spacing: Dimens.smallPadding
            )
                        
            TextIcon(
                icon: Image(systemName: "person.2"),
                text: MissionUtilsPresentation.formatShortParticipantNumber(
                    participantsCount: mission.participants.count,
                    maxParticipants: mission.maxParticipants
                ),
                spacing: Dimens.smallMediumPadding
            )
        }
        .foregroundStyle(Color.informationText)
        .font(.subheadline)
    }
}

private struct CardBody: View {
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
        Text(MissionUtilsPresentation.formatSchoolLevels(schoolLevels: schoolLevels))
            .font(.footnote)
    }
}

private struct ErrorBanner: View {
    var body: some View {
        HStack(spacing: Dimens.smallPadding) {
            Image(systemName: "exclamationmark.circle")
            Text(stringResource(.sendingError))
        }
        .font(.subheadline)
        .foregroundStyle(.error)
        .padding(.vertical, Dimens.smallMediumPadding)
        .padding(.horizontal, Dimens.mediumPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.appBackground.opacity(0.8))
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            DefaultMissionCard(
                mission: missionFixture,
                onOptionsClick: {}
            )
            
            CompletedMissionCard(
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
