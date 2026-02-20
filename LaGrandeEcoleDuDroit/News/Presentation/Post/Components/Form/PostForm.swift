import SwiftUI

struct PostForm: View {
    let value: PostFormValue
    let onTitleChange: (String) -> Void
    let onPostLinkChange: (String) -> Void
    let onPostSourceChange: (Post.PostSource) -> Void
    let onContentChange: (String) -> Void
    let onRemoveImageClick: (Int) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: DimensResource.mediumPadding) {
                PostInputSection(
                    value: value,
                    onTitleChange: onTitleChange,
                    onPostLinkChange: onPostLinkChange,
                    onPostSourceChange: onPostSourceChange,
                    onContentChange: onContentChange
                )
                
                PostFormImageSection(
                    imageReferences: value.imageReferences,
                    onRemoveImageClick: onRemoveImageClick
                )
            }
        }
    }
}

struct PostFormValue {
    @Binding var title: String
    @Binding var postLink: String
    let postSource: Post.PostSource?
    let allPostSources: [Post.PostSource]
    @Binding var content: String
    let imageReferences: [ImageReference]
    let postLinkError: String?
}

#Preview {
    PostForm(
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
        onContentChange: { _ in },
        onRemoveImageClick: { _ in }
    )
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
