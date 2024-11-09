import SwiftUI

struct ProfilePicture: View {
    var url: String
    let scale: CGFloat
    
    init(url: String, scale: CGFloat = 1.0) {
        self.url = url
        self.scale = scale
    }
    
    var body: some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                ZStack {
                    ProgressView()
                        .frame(
                            width: GedNumber.defaultImageSize * scale,
                            height: GedNumber.defaultImageSize * scale
                        )
                        .clipShape(Circle())
                }.overlay {
                    Circle()
                        .stroke(Color(.lightGrey), lineWidth: 1)
                }
                
            case .success(let image):
                ZStack {
                    image
                        .fitCircle(scale: scale)
                }
                
            default: DefaultProfilePicture()
            }
        }
    }
}

struct ClickableProfilePicture: View {
    @State private var isClicked: Bool = false
    var url: String
    let scale: CGFloat
    let onClick: () -> Void
    
    init(url: String, onClick: @escaping () -> Void, scale: CGFloat = 1.0) {
        self.url = url
        self.onClick = onClick
        self.scale = scale
    }
    
    var body: some View {
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
                .background(Color(UIColor.systemBackground))
                .clickable(isClicked: $isClicked, onClick: onClick)
                .overlay {
                    Circle()
                        .stroke(Color(.lightGrey), lineWidth: 1)
                }
                .clipShape(Circle())
                
            case .success(let image):
                ZStack {
                    image
                        .fitCircleClickable(
                            isClicked: $isClicked,
                            onClick: onClick,
                            scale: scale
                        )
                }
                
            default:
                ClickableDefaultProfilePicture(onClick: onClick)
            }
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
    let scale: CGFloat
    let onClick: () -> Void
    
    init(onClick: @escaping () -> Void, scale: CGFloat = 1.0) {
        self.onClick = onClick
        self.scale = scale
    }

    var body: some View {
        Image(ImageResource.defaultProfilePicture)
            .fitCircleClickable(isClicked: $isClicked, onClick: onClick)
    }
}


#Preview {
    let url = "https://icons.veryicon.com/png/o/miscellaneous/user-avatar/user-avatar-male-5.png"

    VStack {
        Text("Default profile picture")
            .font(.caption)
        DefaultProfilePicture()
        
        Text("Clickable default profile picture")
            .font(.caption)
        ClickableDefaultProfilePicture(onClick: {})
        
        Text("Profile picture")
            .font(.caption)
        ProfilePicture(url: url)
        
        Text("Clickable profile picture")
            .font(.caption)
        ClickableProfilePicture(url: url, onClick: {})
    }
}
