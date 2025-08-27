import SwiftUI

struct ProfilePicture: View {
    let imagePhase: ImagePhase
    var scale: CGFloat = 1.0

    var body: some View {
<<<<<<< Updated upstream
        switch imagePhase {
            case .empty: DefaultProfilePicture(scale: scale)

            case .loading:
                ProgressView()
                    .frame(
                        width: GedNumber.defaultImageSize * scale,
                        height: GedNumber.defaultImageSize * scale
                    )
                    .background(.profilePictureLoading)
                    .clipShape(Circle())

            case .success(let data):
                if let uIImage = UIImage(data: data) {
                    Image(uiImage: uIImage).fitCircle(scale: scale)
                } else {
                    ProfilePictureError(scale: scale)
=======
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
                        image
                            .fitCircle(scale: scale)
                            .background(.clear)
                        
                    case .failure:
                        ProfilePictureError(scale: scale)
                        
                    @unknown default:
                        DefaultProfilePicture(scale: scale)
>>>>>>> Stashed changes
                }

            case .failure: ProfilePictureError(scale: scale)
        }
    }
}

struct ClickableProfilePicture: View {
    let imagePhase: ImagePhase
    var scale: CGFloat = 1.0
    let onClick: () -> Void

    @State private var isClicked: Bool = false

    var body: some View {
        switch imagePhase {
            case .empty:
                ClickableDefaultProfilePicture(onClick: onClick, scale: scale)

            case .loading:
                ZStack {
                    ProgressView()
                }
                .frame(
                    width: GedNumber.defaultImageSize * scale,
                    height: GedNumber.defaultImageSize * scale
                )
                .onClick(isClicked: $isClicked, action: onClick)
                .background(.profilePictureLoading)
                .clipShape(Circle())

            case .success(let data):
                if let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .fitCircleClickable(
                            isClicked: $isClicked,
                            onClick: onClick,
                            scale: scale
                        )
                } else {
                    ProfilePictureError(scale: scale)
                        .onClick(isClicked: $isClicked, action: onClick)
                        .clipShape(Circle())
                }

            case .failure:
                ProfilePictureError(scale: scale)
                    .onClick(isClicked: $isClicked, action: onClick)
                    .clipShape(Circle())
        }
    }
}

struct ClickableProfilePictureImage: View {
    @State private var isClicked: Bool = false
    let data: Data?
    let onClick: () -> Void
    var scale: CGFloat = 1.0

    var body: some View {
        if let data = data, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .scaledToFill()
                .frame(
                    width: GedNumber.defaultImageSize * scale,
                    height: GedNumber.defaultImageSize * scale
                )
                .onClick(isClicked: $isClicked, action: onClick)
                .clipShape(Circle())
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

    @State private var isClicked = false

    var body: some View {
        Image(ImageResource.defaultProfilePicture)
            .fitCircleClickable(
                isClicked: $isClicked,
                onClick: onClick,
                scale: scale
            )
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
            Text("Default profile picture").font(.caption)
            DefaultProfilePicture()

            Text("Loading picture").font(.caption)
            ProfilePicture(imagePhase: .loading)

            Text("Error picture").font(.caption)
            ProfilePictureError()
        }
    }
}
