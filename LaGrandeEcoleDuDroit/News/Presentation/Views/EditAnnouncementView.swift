import SwiftUI

struct EditAnnouncementView: View {
    @StateObject private var editAnnouncementViewModel: EditAnnouncementViewModel
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @Environment(\.dismiss) var dismiss
    @FocusState private var inputFieldFocused: InputField?
    @State private var isActive: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var announcement: Announcement
    
    init(announcement: Announcement) {
        self.announcement = announcement
        _editAnnouncementViewModel = StateObject(
            wrappedValue: NewsInjection.shared.resolve(EditAnnouncementViewModel.self, arguments: announcement)!
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            TextField(getString(.title), text: $editAnnouncementViewModel.announcement.title, axis: .vertical)
                .font(.title2)
                .fontWeight(.semibold)
                .focused($inputFieldFocused, equals: InputField.title)
            
            TextField(getString(.content), text: $editAnnouncementViewModel.announcement.content, axis: .vertical)
                .font(.bodyLarge)
                .lineSpacing(5)
                .focused($inputFieldFocused, equals: InputField.content)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .alert(
            errorMessage,
            isPresented: $showErrorAlert
        ) {
            Button(getString(.ok)) {
                showErrorAlert = false
            }
        }
        .navigationTitle(getString(.editAnnouncement))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(
                    action: { dismiss() },
                    label: { Text(getString(.cancel)) }
                )
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: { editAnnouncementViewModel.updateAnnouncement() },
                    label: {
                        if announcement.content.isEmpty ||
                            editAnnouncementViewModel.announcement.title == announcement.title &&
                            editAnnouncementViewModel.announcement.content == announcement.content {
                            Text(getString(.save))
                                .fontWeight(.semibold)
                        } else {
                            Text(getString(.save))
                                .foregroundStyle(.gedPrimary)
                                .fontWeight(.semibold)
                        }
                    }
                )
                .disabled(
                    editAnnouncementViewModel.announcement.content.isEmpty ||
                    (
                        editAnnouncementViewModel.announcement.title == announcement.title &&
                        editAnnouncementViewModel.announcement.content == announcement.content
                    )
                )
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                inputFieldFocused = InputField.title
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            inputFieldFocused = nil
        }
        .onReceive(editAnnouncementViewModel.$screenState) { state in
            if case .error(let message) = state {
                errorMessage = message
                showErrorAlert = true
            } else if case .success = state {
                navigationCoordinator.pop()
            }
        }
    }
}

#Preview {
    EditAnnouncementView(announcement: announcementFixture)
        .environmentObject(NewsInjection.shared.resolve(EditAnnouncementViewModel.self))
}
