import SwiftUI

struct PostImagePages: View {
    let postState: Post.PostState
    @State private var paginationState: PaginationState
    
    init(postState: Post.PostState) {
        self.postState = postState
        self.paginationState = PaginationState(currentPage: 0)
    }

    var body: some View {
        ZStack {
            switch postState {
                case let .published(imageUrls: urls):
                    RemoteImages(paginationState: $paginationState, urls: urls)
                    
                case let .publishing(imagePaths: paths):
                    LocalImages(paginationState: $paginationState, paths: paths)
                    
                case let .error(imagePaths: paths):
                    LocalImages(paginationState: $paginationState, paths: paths)
                    
                default: EmptyView()
            }
            
            if postState.imageReferenceValues.count > 1 {
                PageNumberBadge(
                    index: paginationState.currentPage,
                    totalCount: postState.imageReferenceValues.count
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(DimensResource.smallMediumPadding)
            }
        }
    }
}

private struct RemoteImages: View {
    @Binding var paginationState: PaginationState
    let urls: [String]

    var body: some View {
        PagedCollectionView(
            state: $paginationState,
            values: urls,
            onCellClick: { _ in }
        ) { url in
            CacheAsyncImage(url: url)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct LocalImages: View {
    @Binding var paginationState: PaginationState
    let paths: [String]

    var body: some View {
        PagedCollectionView(
            state: $paginationState,
            values: paths,
            onCellClick: { _ in }
        ) { path in
            LocalImage(imagePath: path)
        }
    }
}

private struct PageNumberBadge: View {
    let index: Int
    let totalCount: Int
    
    var body: some View {
        Text("\(index + 1) / \(totalCount)")
            .font(.caption)
            .foregroundStyle(.white)
            .padding(.horizontal, DimensResource.smallPadding)
            .padding(.vertical, 6)
            .background(.overlayContent)
            .clipShape(ShapeDefaults.large)
    }
}

#Preview {
    PostImagePages(postState: postFixture.state)
}
