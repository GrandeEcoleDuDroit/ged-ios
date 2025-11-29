import SwiftUI
import Combine

struct MissionImage: View {
    let missionState: Mission.MissionState
    var defaultImageScale: CGFloat = 1.2
    
    var body: some View {
        switch missionState {
            case let .publishing(imagePath):
                PublishingMissionImage(
                    imagePath: imagePath,
                    defaultImageScale: defaultImageScale
                )
                
            case let .published(imageUrl):
                PublishedMissionImage(imageUrl: imageUrl, defaultImageScale: defaultImageScale)
                
            case let .error(imagePath):
                ErrorMissionImage(
                    imagePath: imagePath,
                    defaultImageScale: defaultImageScale
                )
            
            default: DefaultImage(scale: defaultImageScale)
        }
    }
}

private struct PublishingMissionImage: View {
    let imagePath: String?
    let defaultImageScale: CGFloat
    
    var body: some View {
        if let imagePath {
            LocalImage(imagePath: imagePath)
        } else {
            DefaultImage(scale: defaultImageScale)
        }
    }
}

private struct PublishedMissionImage: View {
    let imageUrl: String?
    let defaultImageScale: CGFloat
    
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
                        
                    default: DefaultImage(scale: defaultImageScale)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            DefaultImage(scale: defaultImageScale)
        }
    }
}

private struct ErrorMissionImage: View {
    let imagePath: String?
    let defaultImageScale: CGFloat
    
    var body: some View {
        if let imagePath {
            LocalImage(imagePath: imagePath)
        } else {
            DefaultImage(scale: defaultImageScale)
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

private struct DefaultImage: View {
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
            .background(.imageLoading)
    }
}

private struct ErrorImage: View {
    var body: some View {
        Rectangle()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(.imageLoading)
    }
}
