import SwiftUI

struct CompactPostItem: View {
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
                    .frame(height: 160)
            }
            
            if post.content.isNotBlank() {
                ContentSection(content: post.content)
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
            if case .error = state {
                Image(systemName: "exclamationmark.circle")
                    .foregroundStyle(.red)
            }
            
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
