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

private struct PublishedMissionImage<DefaultImage: View>: View {
    let imageUrl: String?
    let defaultImage: DefaultImage

    var body: some View {
        if let imageUrl {
            AsyncImage(url: URL(string: imageUrl)) { phase in
                switch phase {
                    case .empty: LoadingImage()
                        
                    case let .success(image):
                        image
                            .resizable()
                            .scaledToFill()
                            .clipped()
                        
                    case .failure: ErrorImage()
                        
                    default: ErrorImage()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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

private struct LocalImage: View {
    let imagePath: String
    
    var body: some View {
        if let uiImage = UIImage(contentsOfFile: imagePath) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .clipped()
        } else {
            ErrorImage()
        }
    }
}

struct DefaultMissionImage: View {
    let scale: CGFloat
    
    var body: some View {
        Image(systemName: "target")
            .resize(scale: scale)
            .foregroundStyle(.defaultImageForeground)
            .padding(Dimens.mediumPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.surfaceVariant)
    }
}

private struct LoadingImage: View {
    var body: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.imageLoadingBackground)
    }
}

private struct ErrorImage: View {
    var body: some View {
        Rectangle()
            .fill(.imageLoadingBackground)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
