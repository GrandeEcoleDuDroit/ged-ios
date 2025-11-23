import SwiftUI
import PhotosUI

struct MissionFormImageSection: View {
    let imageData: Data?
    let onImageClick: () -> Void
    let onRemoveImageClick: () -> Void
    
    private let viewHeight: CGFloat = 200
    
    var body: some View {
        ZStack {
            if let data = imageData,
               let uiImage = UIImage(data: data) {
                ZStack {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: viewHeight)
                        .frame(maxWidth: .infinity)
                        .clipped()
                    
                    Button(action: onRemoveImageClick) {
                        Image(systemName: "xmark")
                    }
                    .fontWeight(.medium)
                    .padding(Dimens.smallPadding)
                    .background(.imageIconButton)
                    .clipShape(.circle)
                    .padding(Dimens.smallMediumPadding)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .frame(height: viewHeight)
                }
            } else {
                EmptyImage()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: viewHeight)
        .contentShape(Rectangle())
        .onTapGesture(perform: onImageClick)
    }
}

private struct EmptyImage: View {
    var body: some View {
        VStack(spacing: Dimens.extraSmallPadding) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 60))
            
            Text(stringResource(.addImage))
                .font(.bodyLarge)
        }
        .foregroundStyle(.onSurfaceVariant)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGray4))
    }
}

#Preview {
    MissionFormImageSection(
        imageData: nil,
        onImageClick: {},
        onRemoveImageClick: {}
    )
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
