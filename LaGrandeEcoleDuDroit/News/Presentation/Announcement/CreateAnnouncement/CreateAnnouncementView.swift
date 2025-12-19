import SwiftUI

struct CreateAnnouncementDestination: View {
    let onCancelClick: () -> Void
    
    @StateObject private var viewModel = NewsMainThreadInjector.shared.resolve(CreateAnnouncementViewModel.self)
    
    var body: some View {
        NavigationStack {
            CreateAnnouncementView(
                title: $viewModel.uiState.title,
                content: $viewModel.uiState.content,
                createEnabled: viewModel.uiState.createEnabled,
                onTitleChange: viewModel.onTitleChange,
                onContentChange: viewModel.onContentChange,
                onCreateClick: {
                    viewModel.createAnnouncement()
                    onCancelClick()
                },
                onCancelClick: onCancelClick
            )
        }
    }
}

private struct CreateAnnouncementView: View {
    @Binding var title: String
    @Binding var content: String
    let createEnabled: Bool
    let onTitleChange: (String) -> Void
    let onContentChange: (String) -> Void
    let onCreateClick: () -> Void
    let onCancelClick: () -> Void
    
    @FocusState private var focusState: AnnouncementFocusField?
    
    var body: some View {
        AnnouncementInputs(
            title: $title,
            content: $content,
            onTitleChange: onTitleChange,
            onContentChange: onContentChange,
            focusState: _focusState
        )
        .onTapGesture { focusState = nil }
        .navigationTitle(stringResource(.newAnnouncement))
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(stringResource(.cancel)) {
                    onCancelClick()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button(action: onCreateClick) {
                    if createEnabled {
                        Text(stringResource(.publish))
                            .foregroundStyle(.gedPrimary)
                    } else {
                        Text(stringResource(.publish))
                    }
                }
                .disabled(!createEnabled)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                focusState = .title
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateAnnouncementView(
            title: .constant(""),
            content: .constant(""),
            createEnabled: false,
            onTitleChange: { _ in },
            onContentChange: { _ in },
            onCreateClick: {},
            onCancelClick: {}
        )
        .background(.appBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
