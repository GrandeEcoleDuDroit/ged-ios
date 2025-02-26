import SwiftUI

struct EditAnnouncementView: View {
    @EnvironmentObject private var announcementDetailViewModel: AnnouncementDetailViewModel
    @FocusState private var inputFieldFocused: InputField?
    @State private var isActive: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var announcement: Announcement
    
    private let onCancelClick: () -> Void
    private let onSaveClick: (String, String) -> Void
    
    init(
        announcement: Announcement,
        onCancelClick: @escaping () -> Void,
        onSaveClick: @escaping (String, String) -> Void
    ) {
        self._announcement = State(initialValue: announcement)
        self.onCancelClick = onCancelClick
        self.onSaveClick = onSaveClick
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            TextField(getString(.title), text: $announcement.title, axis: .vertical)
                .font(.title2)
                .fontWeight(.semibold)
                .focused($inputFieldFocused, equals: InputField.title)
            
            TextField(getString(.content), text: $announcement.content, axis: .vertical)
                .font(.bodyLarge)
                .lineSpacing(5)
                .focused($inputFieldFocused, equals: InputField.content)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
        .alert(
            "",
            isPresented: $showErrorAlert,
            presenting: ""
        ) { data in
            Button(getString(.ok)) {
                showErrorAlert = false
            }
        } message: { data in
            Text(errorMessage)
        }
        .navigationTitle(getString(.editAnnouncement))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(
                    action: onCancelClick,
                    label: { Text(getString(.cancel)) }
                )
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: { onSaveClick(announcement.title, announcement.content) },
                    label: {
                        if announcement.content.isEmpty ||
                            announcement.title == announcementDetailViewModel.announcement.title &&
                            announcement.content == announcementDetailViewModel.announcement.content {
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
                    announcement.content.isEmpty ||
                    (
                        announcement.title == announcementDetailViewModel.announcement.title &&
                        announcement.content == announcementDetailViewModel.announcement.content
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
    }
}

#Preview {
    EditAnnouncementView(
        announcement: announcementFixture,
        onCancelClick: {},
        onSaveClick: { _, _ in }
    ).environmentObject(NewsInjection.shared.resolve(AnnouncementDetailViewModel.self))
}
