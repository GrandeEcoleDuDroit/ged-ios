import SwiftUI

struct ProfilePicture: View {
    let url: String?
    let scale: CGFloat
    
    init(url: String?, scale: CGFloat = 1.0) {
        self.url = url
        self.scale = scale
    }
    
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
                    default: DefaultProfilePicture(scale: scale)
                }
            }
        } else {
            DefaultProfilePicture(scale: scale)
        }
    }
}

struct ClickableProfilePictureImage: View {
    @State private var isClicked: Bool = false
    let image: UIImage?
    let onClick: () -> Void
    let scale: CGFloat
    
    init(
        image: UIImage?,
        onClick: @escaping () -> Void,
        scale: CGFloat = 1.0
    ) {
        self.image = image
        self.onClick = onClick
        self.scale = scale
    }
    
    var body: some View {
        if let image = image {
            Image(uiImage: image)
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

struct ClickableProfilePicture: View {
    @State private var isClicked: Bool = false
    let url: String?
    let scale: CGFloat
    let onClick: () -> Void
    
    init(url: String, onClick: @escaping () -> Void, scale: CGFloat = 1.0) {
        self.url = url
        self.onClick = onClick
        self.scale = scale
    }
    
    var body: some View {
        if let url = url {
            AsyncImage(url: URL(string: url)) { phase in
                switch phase {
                    case .empty:
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
                        
                    case .success(let image):
                        image
                            .fitCircleClickable(
                                isClicked: $isClicked,
                                onClick: onClick,
                                scale: scale
                            )
                    default: ClickableDefaultProfilePicture(onClick: onClick, scale: scale)
                }
            }
        }
        else {
            ClickableDefaultProfilePicture(onClick: onClick, scale: scale)
        }
    }
}

struct DefaultProfilePicture: View {
    let scale: CGFloat
    
    init(scale: CGFloat = 1.0) {
        self.scale = scale
    }
    
    var body: some View {
        Image(ImageResource.defaultProfilePicture)
            .fitCircle(scale: scale)
    }
}

struct ClickableDefaultProfilePicture: View {
    @State private var isClicked = false
    let onClick: () -> Void
    let scale: CGFloat
    
    init(onClick: @escaping () -> Void, scale: CGFloat = 1.0) {
        self.onClick = onClick
        self.scale = scale
    }
    
    var body: some View {
        Image(ImageResource.defaultProfilePicture)
            .fitCircleClickable(isClicked: $isClicked, onClick: onClick, scale: scale)
    }
}

#Preview {
    let url = "https://icons.veryicon.com/png/o/miscellaneous/user-avatar/user-avatar-male-5.png"
    
    ScrollView {
        VStack {
            DefaultProfilePicture()
            Text("Default profile picture")
                .font(.caption)
            
            ProfilePicture(url: url)
            Text("Profile picture")
                .font(.caption)
            
            ProfilePicture(url: "")
            Text("Loading picture")
                .font(.caption)
        }
    }
}
