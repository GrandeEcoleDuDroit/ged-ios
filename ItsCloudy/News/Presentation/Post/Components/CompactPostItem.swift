import SwiftUI

struct CompactPostItem: View {
    let post: Post
    let onRedirectPostClick: () -> Void
    let onOptionClick: () -> Void
    
    var body: some View {
        switch post.state {
            case .published, .draft:
                DefaultItem(
                    post: post,
                    onRedirectPostClick: onRedirectPostClick,
                    onOptionClick: onOptionClick
                )
                
            case .publishing:
                PublishingItem(
                    post: post,
                    onRedirectPostClick: onRedirectPostClick,
                    onOptionClick: onOptionClick
                )
                
            case .error:
                ErrorItem(
                    post: post,
                    onRedirectPostClick: onRedirectPostClick,
                    onOptionClick: onOptionClick
                )
        }
    }
}

private struct DefaultItem: View {
    let post: Post
    let onRedirectPostClick: () -> Void
    let onOptionClick: () -> Void
    
    var body: some View {
        VStack(spacing: DimensResource.smallMediumPadding) {
            TitleSection(
                title: post.title,
                state: post.state,
                onOptionClick: onOptionClick
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if !post.state.imageReferenceValues.isEmpty {
                ImageSection(postState: post.state)
                    .frame(maxWidth: .infinity)
            }
            
            if let content = post.content, !content.isEmpty {
                ContentSection(content: content)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            FooterSection(
                postSource: post.source,
                date: post.date,
                onRedirectPostClick: onRedirectPostClick
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct PublishingItem: View {
    let post: Post
    let onRedirectPostClick: () -> Void
    let onOptionClick: () -> Void
    
    var body: some View {
        DefaultItem(
            post: post,
            onRedirectPostClick: onRedirectPostClick,
            onOptionClick: onOptionClick
        ).opacity(0.5)
    }
}

private struct ErrorItem: View {
    let post: Post
    let onRedirectPostClick: () -> Void
    let onOptionClick: () -> Void
    
    var body: some View {
        VStack(spacing: DimensResource.smallMediumPadding) {
            HStack(spacing: DimensResource.smallMediumPadding) {
                Image(systemName: "exclamationmark.circle")
                    .foregroundStyle(.red)
                
                TitleSection(
                    title: post.title,
                    state: post.state,
                    onOptionClick: onOptionClick
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if !post.state.imageReferenceValues.isEmpty {
                ImageSection(postState: post.state)
                    .frame(maxWidth: .infinity)
            }
            
            if let content = post.content, !content.isEmpty {
                ContentSection(content: content)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            FooterSection(
                postSource: post.source,
                date: post.date,
                onRedirectPostClick: onRedirectPostClick
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct TitleSection: View {
    let title: String
    let state: Post.PostState
    let onOptionClick: () -> Void
    
    var body: some View {
        HStack(spacing: DimensResource.smallMediumPadding) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            OptionsButton(action: onOptionClick)
                .buttonStyle(.borderless)
        }
    }
}

private struct ImageSection: View {
    let postState: Post.PostState
    
    var body: some View {
        PostImagePages(postState: postState)
            .clipShape(ShapeDefaults.medium)
            .frame(height: DimensResource.News.compactPostImageHeight)
    }
}

private struct ContentSection: View {
    let content: String
    
    var body: some View {
        Text(content)
            .font(.footnote)
    }
}

private struct FooterSection: View {
    let postSource: Post.PostSource
    let date: Date
    let onRedirectPostClick: () -> Void
    
    var body: some View {
        HStack {
            PostSourceItem(postSource: postSource, date: date)
            
            Spacer()
            
            OutlinedButton(
                stringResource(.see),
                action: onRedirectPostClick
            )
        }
    }
}

#Preview {
    CompactPostItem(
        post: postFixture,
        onRedirectPostClick: {},
        onOptionClick: {}
    )
}
