import SwiftUI
import Combine

struct MissionImage<DefaultImage: View>: View {
    let missionState: Mission.MissionState
    let defaultImage: DefaultImage

    init(
        missionState: Mission.MissionState,
        defaultImage: DefaultImage
    ) {
        self.missionState = missionState
        self.defaultImage = defaultImage
    }
    
    var body: some View {
        switch missionState {
            case let .publishing(imagePath):
                PublishingMissionImage(
                    imagePath: imagePath,
                    defaultImage: defaultImage
                )
                
            case let .published(imageUrl):
                PublishedMissionImage(
                    imageUrl: imageUrl,
                    defaultImage: defaultImage
                )
                
            case let .error(imagePath):
                ErrorMissionImage(
                    imagePath: imagePath,
                    defaultImage: defaultImage
                )
            
            default: defaultImage
        }
    }
}

extension MissionImage {
    init(
        missionState: Mission.MissionState,
        defaultImageScale: CGFloat = 1.2
    ) where DefaultImage == DefaultMissionImage  {
        self.missionState = missionState
        self.defaultImage = DefaultMissionImage(scale: defaultImageScale)
    }
}

private struct PublishedMissionImage<DefaultImage: View>: View {
    let imageUrl: String?
    let defaultImage: DefaultImage

    var body: some View {
        if let imageUrl {
            CacheAsyncImage(url: imageUrl)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            defaultImage
        }
    }
}

private struct PublishingMissionImage<DefaultImage: View>: View {
    let imagePath: String?
    let defaultImage: DefaultImage
    
    var body: some View {
        if let imagePath {
            LocalImage(imagePath: imagePath)
        } else {
           defaultImage
        }
    }
}

private struct ErrorMissionImage<DefaultImage: View>: View {
    let imagePath: String?
    let defaultImage: DefaultImage

    var body: some View {
        if let imagePath {
            LocalImage(imagePath: imagePath)
        } else {
            defaultImage
        }
    }
}

struct DefaultMissionImage: View {
    let scale: CGFloat
    
    var body: some View {
        Image(systemName: "target")
            .resizable()
            .scaledToFit()
            .frame(
                width: DimensResource.defaultImageSize * scale,
                height: DimensResource.defaultImageSize * scale
            )
            .clipped()
            .foregroundStyle(.defaultImageForeground)
            .padding(DimensResource.mediumPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.surfaceVariant)
    }
}

#Preview("Default mission image") {
    DefaultMissionImage(scale: 2)
}
