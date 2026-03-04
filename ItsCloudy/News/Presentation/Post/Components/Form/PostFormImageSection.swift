import SwiftUI

struct PostFormImageSection: View {
    let imageReferences: [ImageReference]
    let onRemoveImageClick: (Int) -> Void
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: DimensResource.mediumPadding) {
                ForEach(imageReferences.indices, id: \.self) { index in
                    ImageRailItem(
                        imageReference: imageReferences[index],
                        width: DimensResource.News.createPostImageRailItemWidth,
                        height: DimensResource.News.createPostImageRailItemHeight,
                        onRemoveImageClick: { onRemoveImageClick(index) }
                    )
                }
            }
        }
    }
}

private struct ImageRailItem: View {
    let imageReference: ImageReference
    let width: CGFloat
    let height: CGFloat
    let onRemoveImageClick: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            HybridImage(
                imageReference: imageReference,
                width: width,
                height: height
            )
            
            RemoveImageButton(action: onRemoveImageClick)
        }
        .clipShape(ShapeDefaults.small)
        .frame(width: width, height: height)
    }
}

private struct RemoveImageButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 10, height: 10)
                .foregroundStyle(.white)
                .padding(DimensResource.smallPadding)
                .background(.imageIconButtonContainer)
        }
        .clipShape(.circle)
        .padding(DimensResource.smallPadding)

    }
}

#Preview {
    PostFormImageSection(
        imageReferences: postFixture.state.imageReferenceValues.map(ImageReference.imageUrl),
        onRemoveImageClick: {_ in }
    )
}
