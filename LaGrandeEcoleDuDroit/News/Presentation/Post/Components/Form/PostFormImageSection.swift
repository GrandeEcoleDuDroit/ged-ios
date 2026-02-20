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
                        width: 180,
                        height: 220,
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
            
            Button(action: onRemoveImageClick) {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(.imageIconButtonContainer)
            }
            .clipShape(.circle)
            .padding(DimensResource.smallPadding)
        }
        .clipShape(ShapeDefaults.small)
        .frame(width: width, height: height)
    }
}

#Preview {
    PostFormImageSection(
        imageReferences: postFixture.state.imageReferenceValues.map(ImageReference.imageUrl),
        onRemoveImageClick: {_ in }
    )
}
