import SwiftUI
import PhotosUI

struct PostForm: View {
    let value: PostFormValue
    let onTitleChange: (String) -> Void
    let onPostLinkChange: (String) -> Void
    let onPostSourceChange: (Post.PostSource) -> Void
    let onContentChange: (String) -> Void
    let onAddImageData: ([Data]) -> Void
    let onRemoveImageClick: (Int) -> Void
    
    @State private var showPhotoPicker: Bool = false
    @State private var selectedItems: [PhotosPickerItem] = []
    @FocusState private var focusState: PostFormFocusField?
    
    var body: some View {
        ScrollView {
            VStack(spacing: DimensResource.mediumPadding) {
                PostInputSection(
                    value: value,
                    focusState: _focusState,
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
        .scrollDismissesKeyboard(.interactively)
        .scrollIndicators(.hidden)
        .photosPicker(
            isPresented: $showPhotoPicker,
            selection: $selectedItems,
            maxSelectionCount: PostPresentationUtils.maxImageCount,
            matching: .images
        )
        .task(id: selectedItems) {
            var imageData: [Data] = []
            for item in selectedItems {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let compressedData = UIImage(data: data)?.jpeg(.medium) {
                    imageData.append(compressedData)
                }
            }
            onAddImageData(imageData)
            selectedItems.removeAll()
        }
        .safeAreaInset(edge: .bottom) {
            BottomSection(onAddImageClick: {
                focusState = nil
                showPhotoPicker = true
            })
            .padding(.vertical)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.appBackground)
            .foregroundStyle(.onSurfaceVariant)
        }
    }
}

private struct BottomSection: View {
    let onAddImageClick: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onAddImageClick) {
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: DimensResource.smallMediumIconSIze, height: DimensResource.smallMediumIconSIze)
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

enum PostFormFocusField: Hashable {
    case title
    case link
    case content
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
        onAddImageData: { _ in },
        onRemoveImageClick: { _ in }
    )
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
