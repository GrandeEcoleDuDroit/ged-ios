import SwiftUI

struct GedNewsSection: View {
    let posts: [Post]?
    let onPostClick: (Post) -> Void
    let onUncreatedPostClick: () -> Void
    let onRedirectPostClick: (String) -> Void
    let onPostOptionClick: (Post) -> Void
    let onSeeAllPostsClick: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: DimensResource.smallMediumPadding) {
                SectionTitle(title: stringResource(.gedNews))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(
                    stringResource(.seeAll),
                    action: onSeeAllPostsClick
                )
                .foregroundStyle(.gedPrimary)
                .font(.callout)
            }
            .padding(.horizontal)
            
            if let posts {
                if posts.isEmpty {
                    EmptyText(stringResource(.noNews))
                } else {
                    PagedCollectionView(
                        values: posts,
                        onCellClick: onPostClick
                    ) { post in
                        CompactPostItem(
                            post: post,
                            onRedirectPostClick: { onRedirectPostClick(post.link) },
                            onOptionClick: { onPostOptionClick(post) }
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
}

#Preview {
    GedNewsSection(
        posts: postsFixture,
        onPostClick: {_ in },
        onUncreatedPostClick: {},
        onRedirectPostClick: { _ in},
        onPostOptionClick: { _ in},
        onSeeAllPostsClick: {}
    )
}
