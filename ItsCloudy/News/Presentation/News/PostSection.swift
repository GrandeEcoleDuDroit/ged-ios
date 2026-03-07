import SwiftUI

struct PostSection: View {
    let posts: [Post]?
    let onPostClick: (Post) -> Void
    let onUncreatedPostClick: (Post) -> Void
    let onRedirectPostClick: (String) -> Void
    let onPostOptionClick: (Post) -> Void
    let onSeeAllPostsClick: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: DimensResource.smallMediumPadding) {
                SectionTitle(title: stringResource(.postSectionTitle))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button(
                    stringResource(.seeAll),
                    action: onSeeAllPostsClick
                )
                .foregroundStyle(.appPrimary)
                .font(.callout)
            }
            .padding(.horizontal)
            
            if let posts {
                if posts.isEmpty {
                    EmptyText(stringResource(.noPost))
                } else {
                    PagedCollectionView(
                        values: posts,
                        onCellClick: { _ in }
                    ) { post in
                        CompactPostItem(
                            post: post,
                            onRedirectPostClick: { onRedirectPostClick(post.link) },
                            onOptionClick: { onPostOptionClick(post) }
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.horizontal)
                        .contentShape(.rect)
                        .onTapGesture {
                            if post.state.type == .publishedType {
                                onPostClick(post)
                            } else {
                                onUncreatedPostClick(post)
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    PostSection(
        posts: postsFixture,
        onPostClick: {_ in },
        onUncreatedPostClick: { _ in },
        onRedirectPostClick: { _ in},
        onPostOptionClick: { _ in},
        onSeeAllPostsClick: {}
    )
}
