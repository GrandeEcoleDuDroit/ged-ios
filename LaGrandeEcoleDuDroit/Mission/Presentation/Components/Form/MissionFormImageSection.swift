import SwiftUI
import PhotosUI

struct MissionFormImageSection: View {
    @Binding var imageData: Data?
    let missionState: Mission.MissionState
    let onImageChange: () -> Void
    let onImageRemove: () -> Void
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var showPhotosPicker: Bool = false
    
    var body: some View {
        ZStack {
            PhotosPicker(
                selection: $selectedItem,
                matching: .images
            ) {
                if let data = imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: MissionPresentationUtils.missionImageHeight)
                        .frame(maxWidth: .infinity)
                        .clipped()
                } else {
                    MissionImage(
                        missionState: missionState,
                        defaultImage: EmptyImage()
                    )
                    .frame(height: MissionPresentationUtils.missionImageHeight)
                    .clipped()
                }
            }
            
            if imageData != nil || missionState.imageReference != nil {
                Button(
                    action: {
                        imageData = nil
                        onImageRemove()
                    }
                ) {
                    Image(systemName: "xmark")
                }
                .padding(10)
                .background(.imageIconButtonContainer)
                .clipShape(.circle)
                .padding(Dimens.smallMediumPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .frame(height: MissionPresentationUtils.missionImageHeight)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: MissionPresentationUtils.missionImageHeight)
        .contentShape(Rectangle())
        .task(id: selectedItem) {
            if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                imageData = data
                onImageChange()
            }
        }
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
        .background(.emptyImageBackground)
    }
}

#Preview {
    MissionFormImageSection(
        imageData: .constant(nil),
        missionState: .published(imageUrl: ""),
        onImageChange: {},
        onImageRemove: {}
    )
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
