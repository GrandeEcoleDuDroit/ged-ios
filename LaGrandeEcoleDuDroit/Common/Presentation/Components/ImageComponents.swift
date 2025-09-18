import SwiftUI

struct ProfilePicture: View {
    let url: String?
    var scale: CGFloat = 1.0
   
    var body: some View {
        if let url = url {
            AsyncImage(url: URL(string: url)) { phase in
                switch phase {
                    case .empty:
                        ProgressView()
                            .frame(
                                width: GedNumber.defaultImageSize * scale,
                                height: GedNumber.defaultImageSize * scale
                            )
                            .background(.profilePictureLoading)
                            .clipShape(Circle())
                        
                    case .success(let image):
                        image.fitCircle(scale: scale)
                        
                    case .failure:
                        ProfilePictureError(scale: scale)
                        
                    @unknown default:
                        DefaultProfilePicture(scale: scale)
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
        if let url = url {
            AsyncImage(url: URL(string: url)) { phase in
                switch phase {
                    case .empty:
                        Clickable(action: onClick) {
                            ZStack {
                                ProgressView()
                            }
                            .frame(
                                width: GedNumber.defaultImageSize * scale,
                                height: GedNumber.defaultImageSize * scale
                            )
                            .background(.profilePictureLoading)
                            .clipShape(Circle())
                        }
                        .clipShape(Circle())
                        
                    case .success(let image):
                        Clickable(action: onClick) {
                            image.fitCircle(scale: scale)
                        }
                        .clipShape(Circle())
                        
                    case .failure:
                        Clickable(action: onClick) {
                            ProfilePictureError(scale: scale)
                                .clipShape(Circle())
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
        if let image = image {
            Clickable(action: onClick) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaledToFill()
                    .frame(
                        width: GedNumber.defaultImageSize * scale,
                        height: GedNumber.defaultImageSize * scale
                    )
                    .clipShape(Circle())
            }
        } else {
            ClickableDefaultProfilePicture(onClick: onClick, scale: scale)
        }
    }
}

private struct DefaultProfilePicture: View {
    var scale: CGFloat = 1.0
    
    var body: some View {
        Image(ImageResource.defaultProfilePicture)
            .fitCircle(scale: scale)
    }
}

private struct ClickableDefaultProfilePicture: View {
    let onClick: () -> Void
    var scale: CGFloat = 1.0
        
    var body: some View {
        Clickable(action: onClick) {
            Image(ImageResource.defaultProfilePicture)
                .fitCircle(scale: scale)
        }
        .clipShape(Circle())
    }
}

private struct ProfilePictureError: View {
    var scale: CGFloat = 1.0
    
    var body: some View {
        Circle()
            .frame(
                width: GedNumber.defaultImageSize * scale,
                height: GedNumber.defaultImageSize * scale
            )
            .foregroundStyle(.profilePictureLoading)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: GedSpacing.medium) {
            Text("Default profile picture")
                .font(.caption)
            DefaultProfilePicture()
            
            Text("Loading picture")
                .font(.caption)
            ProfilePicture(url: "")
            
            Text("Error picture")
                .font(.caption)
            ProfilePictureError()
            
            Text("Clickable default profile picture")
                .font(.caption)
            ClickableDefaultProfilePicture(onClick: {})
        }
    }
}
