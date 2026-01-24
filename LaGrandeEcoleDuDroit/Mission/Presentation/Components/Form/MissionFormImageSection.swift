import SwiftUI
import PhotosUI

struct MissionFormImageSection: View {
    let imageData: Data?
    let missionState: Mission.MissionState
    let onImageChange: (Data) -> Void
    let onImageRemove: () -> Void
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var showPhotosPicker: Bool = false
    
    var body: some View {
        ZStack {
            PhotosPicker(
                selection: $selectedItem,
                matching: .images
            ) {
                if let data = imageData,
                    let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(height: MissionUtilsPresentation.missionImageHeight)
                        .frame(maxWidth: .infinity)
                        .clipped()
                } else {
                    MissionImage(
                        missionState: missionState,
                        defaultImage: EmptyImage()
                    )
                    .frame(height: MissionUtilsPresentation.missionImageHeight)
                    .clipped()
                }
            }
            
            if imageData != nil || missionState.imageReference != nil {
                Button(action: onImageRemove) {
                    Image(systemName: "xmark")
                }
                .padding(10)
                .background(.imageIconButtonContainer)
                .clipShape(.circle)
                .padding(DimensResource.smallMediumPadding)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .frame(height: MissionUtilsPresentation.missionImageHeight)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: MissionUtilsPresentation.missionImageHeight)
        .contentShape(Rectangle())
        .task(id: selectedItem) {
            if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                onImageChange(data)
            }
        }
    }
}

private struct EmptyImage: View {
    var body: some View {
        VStack(spacing: DimensResource.extraSmallPadding) {
            Image(systemName: "photo.badge.plus")
                .font(.system(size: 60))
            
            Text(stringResource(.addImage))
                .font(.headline)
                .fontWeight(.regular)
        }
        .foregroundStyle(.onSurfaceVariant)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.emptyImageBackground)
    }
}

#Preview {
    MissionFormImageSection(
        imageData: nil,
        missionState: .draft,
        onImageChange: { _ in },
        onImageRemove: {}
    )
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
