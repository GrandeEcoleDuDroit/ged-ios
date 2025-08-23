import SwiftUI

struct AccountImage: View {
    var imagePhase: ImagePhase
    let onClick: () -> Void
    let scale: CGFloat
    
    init(
        imagePhase: ImagePhase,
        onClick: @escaping () -> Void,
        scale: CGFloat = 1.0
    ) {
        self.imagePhase = imagePhase
        self.onClick = onClick
        self.scale = scale
    }
    
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ClickableProfilePicture(imagePhase: imagePhase, scale: scale, onClick: onClick)
            
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
        AccountImage(imagePhase: .empty, onClick: {})

        AccountInfoItem(title: "Name", value: "John Doe")
    }.padding()
}
