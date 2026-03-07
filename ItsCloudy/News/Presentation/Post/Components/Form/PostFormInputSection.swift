import SwiftUI

struct PostInputSection: View {
    let value: PostFormValue
    @FocusState var focusState: PostFormFocusField?
    let onTitleChange: (String) -> Void
    let onPostLinkChange: (String) -> Void
    let onPostSourceChange: (Post.PostSource) -> Void
    let onContentChange: (String) -> Void
    
    var body: some View {
        VStack(spacing: DimensResource.mediumPadding) {
            TransparentTextField(
                stringResource(.titleFieldPlaceholder),
                text: value.$title,
                focusState: _focusState,
                field: .title
            )
            .font(.title2)
            .onChange(of: value.title, perform: onTitleChange)
            .frame(maxWidth: .infinity)
            
            PostLinkInput(
                postLink: value.$postLink,
                postLinkError: value.postLinkError,
                focusState: _focusState,
                field: .link,
                onPostLinkChange: onPostLinkChange
            )
            
            PostSourceInput(
                selectedPostSource: value.postSource,
                allPostSources: value.allPostSources,
                onPostSourceChange: onPostSourceChange
            )
            
            TransparentTextField(
                stringResource(.contentFieldPlaceholder),
                text: value.$content,
                focusState: _focusState,
                field: .content
            )
            .font(.body)
            .onChange(of: value.content, perform: onContentChange)
        }
    }
}

private struct PostLinkInput: View {
    @Binding var postLink: String
    let postLinkError: String?
    @FocusState var focusState: PostFormFocusField?
    let field: PostFormFocusField?
    let onPostLinkChange: (String) -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "link")
                    .resizable()
                    .frame(width: DimensResource.smallMediumIconSIze, height: DimensResource.smallMediumIconSIze)
                    .foregroundStyle(.onSurfaceVariant)
                
                TransparentTextField(
                    stringResource(.postLinkFieldPlaceholder),
                    text: $postLink,
                    focusState: _focusState,
                    field: .link,
                    axis: .horizontal
                )
                .lineLimit(1)
                .textInputAutocapitalization(.never)
                .onChange(of: postLink, perform: onPostLinkChange)
                .frame(maxWidth: .infinity)
                .font(.callout)
            }
            
            if let postLinkError {
                Text(postLinkError)
                    .foregroundColor(.error)
                    .font(.footnote)
                    .padding(.leading, DimensResource.smallIconSIze + DimensResource.smallPadding)
                    .padding(.top, DimensResource.supportingTextTopPadding)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct PostSourceInput: View {
    let selectedPostSource: Post.PostSource?
    let allPostSources: [Post.PostSource]
    let onPostSourceChange: (Post.PostSource) -> Void
    
    var body: some View {
        HStack(spacing: DimensResource.smallMediumPadding) {
            Image(systemName: "globe")
                .resizable()
                .frame(width: DimensResource.smallMediumIconSIze, height: DimensResource.smallMediumIconSIze)
                .foregroundStyle(.onSurfaceVariant)

            ForEach(allPostSources) { postSource in
                FilterChip(
                    label: postSource.label,
                    selected: postSource == selectedPostSource,
                    onClick: { onPostSourceChange(postSource) }
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    PostInputSection(
        value: PostFormValue(
            title: .constant(""),
            postLink: .constant(""),
            postSource: nil,
            allPostSources: Post.PostSource.all,
            content: .constant(""),
            imageReferences: [],
            postLinkError: nil
        ),
        onTitleChange: { _ in },
        onPostLinkChange: { _ in },
        onPostSourceChange: { _ in },
        onContentChange: { _ in }
    )
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
