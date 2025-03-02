import SwiftUI

struct EditAnnouncementView: View {
    @StateObject private var editAnnouncementViewModel: EditAnnouncementViewModel
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @FocusState private var inputFieldFocused: InputField?
    @State private var isActive: Bool = false
    @State private var toastMessage: String = ""
    @State private var announcement: Announcement
    @State private var showLoadingToast: Bool = false
    @State private var showErrorToast: Bool = false
    
    init(announcement: Announcement) {
        self.announcement = announcement
        _editAnnouncementViewModel = StateObject(
            wrappedValue: NewsInjection.shared.resolve(EditAnnouncementViewModel.self, arguments: announcement)!
        )
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            TextField(
                getString(.title),
                text: $editAnnouncementViewModel.announcement.title,
                axis: .vertical
            )
            .font(.title2)
            .fontWeight(.semibold)
            .focused($inputFieldFocused, equals: InputField.title)
        
            TextField(
                getString(.content),
                text: $editAnnouncementViewModel.announcement.content,
                axis: .vertical
            )
            .font(.bodyLarge)
            .lineSpacing(5)
            .focused($inputFieldFocused, equals: InputField.content)
        }
        .disabled(showLoadingToast)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .navigationTitle(getString(.editAnnouncement))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(getString(.cancel)) {
                    navigationCoordinator.pop()
                }
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
        .disabled(showLoadingToast)
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
            switch state {
                case .error(let message):
                    withAnimation {
                        showLoadingToast = false
                    }
                    toastMessage = message
                    showErrorToast = true
                    editAnnouncementViewModel.updateScreenState(.initial)
                case .loading:
                    showLoadingToast = true
                case .updated:
                    showLoadingToast = false
                    navigationCoordinator.pop()
                default: break
            }
        }
        .toast(isPresented: $showLoadingToast, message: getString(.loading), position: .center, type: .loading)
        .toast(isPresented: $showErrorToast, message: toastMessage)
    }
}

#Preview {
    NavigationStack {
        EditAnnouncementView(announcement: announcementFixture)
            .environmentObject(NavigationCoordinator())
    }
}
