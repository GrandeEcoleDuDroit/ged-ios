import SwiftUI

struct MissionCard: View {
    let mission: Mission
    let onClick: () -> Void
    let onOptionClick: () -> Void
    
    var body: some View {
        switch mission.state {
            case .published(let imageUrl):
                Clickable(action: onClick) {
                    DefaultMissionCard(
                        mission: mission,
                        imageModel: imageUrl,
                        onOptionClick: onOptionClick
                    )
                }
                .clipShape(ShapeDefaults.medium)
                
            case .publishing(let imagePath):
                Clickable(action: onClick) {
                    PublishingMissionCard(
                        mission: mission,
                        imageModel: imagePath,
                        onOptionClick: onOptionClick
                    )
                }.clipShape(ShapeDefaults.medium)
                
            case .error(let imagePath):
                Clickable(action: onClick) {
                    ErrorMissionCard(
                        mission: mission,
                        imageModel: imagePath
                    )
                }.clipShape(ShapeDefaults.medium)
                
            default: EmptyView()
        }
    }
}

private struct DefaultMissionCard: View {
    let mission: Mission
    let imageModel: String?
    let onOptionClick: () -> Void
    
    var body: some View {
        VStack(spacing: Dimens.mediumPadding) {
            ZStack {
                MissionImage(model: imageModel)
                
                OptionButton(action: onOptionClick)
                    .padding()
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
        .clipShape(ShapeDefaults.medium)
    }
}

private struct PublishingMissionCard: View {
    let mission: Mission
    let imageModel: String?
    let onOptionClick: () -> Void
    
    var body: some View {
        DefaultMissionCard(
            mission: mission,
            imageModel: imageModel,
            onOptionClick: onOptionClick
        )
        .opacity(0.5)
    }
}

private struct ErrorMissionCard: View {
    let mission: Mission
    let imageModel: String?
    
    var body: some View {
        VStack {
            ZStack {
                MissionImage(model: imageModel)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
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
            .padding()
        }
        .overlay(
            ShapeDefaults.medium
                .stroke(.outlineVariant, lineWidth: 2)
        )
        .clipShape(ShapeDefaults.medium)
    }
}

private struct CardHeader: View {
    let mission: Mission
    
    var body: some View {
        VStack(alignment: .leading, spacing: Dimens.smallPadding) {
            HStack(alignment: .top, spacing: Dimens.smallPadding) {
                Text(mission.title)
                    .font(.title)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                TextIcon(
                    icon: { Image(systemName: "person.3") },
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
                .padding(.top, Dimens.smallPadding)
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
        .padding(.vertical, Dimens.smallPadding + 2)
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
                imageModel: nil,
                onOptionClick: {}
            )
            
            PublishingMissionCard(
                mission: missionFixture,
                imageModel: nil,
                onOptionClick: {}
            )
            
            ErrorMissionCard(
                mission: missionFixture,
                imageModel: nil
            )
        }
        .padding()
    }
}
