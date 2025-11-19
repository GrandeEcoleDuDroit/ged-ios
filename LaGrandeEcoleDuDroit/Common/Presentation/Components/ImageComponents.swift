import SwiftUI

struct ProfilePicture: View {
    let url: String?
    var scale: CGFloat = 1.0
   
    var body: some View {
        if let url {
            AsyncImage(url: URL(string: url)) { phase in
                switch phase {
                    case .empty: LoadingImage(scale: scale).clipShape(Circle())
                        
                    case let .success(image): image.fit(scale: scale).clipShape(Circle())
                        
                    case .failure: ErrorImage(scale: scale).clipShape(Circle())
                        
                    default: DefaultProfilePicture(scale: scale)
                }
            }
        } else {
            DefaultProfilePicture(scale: scale)
        }
    }
}

struct ClickableProfilePicture: View {
    let url: String?
    var scale: CGFloat = 1.0
    let onClick: () -> Void
    
    var body: some View {
        if let url {
            AsyncImage(url: URL(string: url)) { phase in
                switch phase {
                    case .empty:
                        Clickable(action: onClick) {
                            ZStack {
                                ProgressView()
                            }
                            .frame(
                                width: Dimens.defaultImageSize * scale,
                                height: Dimens.defaultImageSize * scale
                            )
                            .background(.imageLoading)
                            .clipShape(Circle())
                        }
                        .clipShape(Circle())
                        
                    case .success(let image):
                        Clickable(action: onClick) {
                            image.fit(scale: scale).clipShape(Circle())

                        }
                        .clipShape(Circle())
                        
                    case .failure:
                        Clickable(action: onClick) {
                            ErrorImage(scale: scale).clipShape(Circle())
                        }
                        .clipShape(Circle())
                        
                    default: ClickableDefaultProfilePicture(onClick: onClick, scale: scale)
                }
            }
        }
        else {
            ClickableDefaultProfilePicture(onClick: onClick, scale: scale)
        }
    }
}

struct ClickableProfilePictureImage: View {
    let image: UIImage?
    let onClick: () -> Void
    var scale: CGFloat = 1.0
    
    var body: some View {
        if let image {
            Clickable(action: onClick) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFill()
                    .frame(
                        width: Dimens.defaultImageSize * scale,
                        height: Dimens.defaultImageSize * scale
                    )
                    .clipShape(Circle())
            }
        } else {
            ClickableDefaultProfilePicture(onClick: onClick, scale: scale)
        }
    }
}

struct SimpleAsyncImage: View {
    let url: String
    var scale: CGFloat = 1.0

    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
                case .empty: LoadingImage(scale: scale)

                case .success(let image): image.fit(scale: scale)

                case .failure: ErrorImage(scale: scale)
                    
                default: DefaultProfilePicture(scale: scale)
            }
        }
    }
}

private struct DefaultProfilePicture: View {
    var scale: CGFloat = 1.0
    
    var body: some View {
        Image(ImageResource.defaultProfilePicture)
            .fit(scale: scale)
            .clipShape(Circle())
    }
}

private struct ClickableDefaultProfilePicture: View {
    let onClick: () -> Void
    var scale: CGFloat = 1.0
        
    var body: some View {
        Clickable(action: onClick) {
            Image(ImageResource.defaultProfilePicture)
                .fit(scale: scale)
                .clipShape(Circle())
        }
        .clipShape(Circle())
    }
}

private struct LoadingImage: View {
    var scale: CGFloat = 1.0
    
    var body: some View {
        ProgressView()
            .frame(
                width: Dimens.defaultImageSize * scale,
                height: Dimens.defaultImageSize * scale
            )
            .background(.imageLoading)
    }
}

private struct ErrorImage: View {
    var scale: CGFloat = 1.0
    
    var body: some View {
        Rectangle()
            .frame(
                width: Dimens.defaultImageSize * scale,
                height: Dimens.defaultImageSize * scale
            )
            .foregroundStyle(.imageLoading)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Dimens.mediumPadding) {
            SimpleAsyncImage(url: "https://cdn.britannica.com/16/234216-050-C66F8665/beagle-hound-dog.jpg")
            Text("Simple async image").font(.caption)
            
            LoadingImage()
            Text("Loading image").font(.caption)
            
            ErrorImage()
            Text("Error image").font(.caption)
            
            ProfilePicture(url: "")
            Text("Profile picture").font(.caption)
            
            DefaultProfilePicture()
            Text("Default profile picture").font(.caption)
            
            ClickableDefaultProfilePicture(onClick: {})
            Text("Clickable default profile picture").font(.caption)
        }
    }
}
