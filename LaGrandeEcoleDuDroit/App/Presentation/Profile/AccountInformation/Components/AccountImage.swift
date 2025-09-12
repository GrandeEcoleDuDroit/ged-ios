import SwiftUI

struct AccountImage: View {
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
            ClickableProfilePicture(url: url, scale: scale, onClick: onClick)
            
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
        AccountImage(url: nil, onClick: {})

        AccountInformationFieldItem(title: "Name", value: "John Doe")
    }.padding()
}
