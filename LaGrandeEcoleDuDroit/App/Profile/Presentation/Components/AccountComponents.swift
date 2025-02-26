import SwiftUI

struct AccountInfoItem: View {
    var title: String
    var value: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.callout)
                .bold()
                .foregroundColor(.previewText)
            
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ProfilePictureEdit: View {
    var url: String?
    let onClick: () -> Void
    let scale: CGFloat
    
    init(
        url: String?,
        onClick: @escaping () -> Void,
        scale: CGFloat = 1.0
    ) {
        self.url = url
        self.onClick = onClick
        self.scale = scale
    }
    
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let url = url {
                ClickableProfilePicture(url: url, onClick: onClick, scale: scale)
            }
            else {
                ClickableDefaultProfilePicture(onClick: onClick, scale: scale)
            }
            
            ZStack {
                Circle()
                    .fill(.gedPrimary)
                    .frame(width: 30 * scale, height: 30 * scale)
                
                Image(systemName: "pencil")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15 * scale, height: 15 * scale)
                    .foregroundColor(.white)
            }
        }
    }
}


#Preview {
    VStack(spacing: 10) {
        ProfilePictureEdit(url: nil, onClick: {})

        AccountInfoItem(title: "Name", value: "John Doe")
    }.padding()
}
