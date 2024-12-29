import SwiftUI

struct EditAnnouncementView: View {
    @EnvironmentObject private var newsViewModel: NewsViewModel
    @Environment(\.dismiss) var dismiss
    private let announcement: Announcement
    @State private var isActive: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var title: String
    @State private var content: String

    init(announcement: Announcement) {
        self.announcement = announcement
        self.title = announcement.title ?? ""
        self.content = announcement.content
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                topBar
                
                DynamicTextEditor(
                    text: $title,
                    placeholderText: Text(getString(.title)).font(.system(size: 22, weight: .semibold)),
                    minHeight: geometry.size.height / 14,
                    maxHeight: geometry.size.height / 6
                )
                .font(.system(size: 22, weight: .semibold))
                
                DynamicTextEditor(
                    text: $content,
                    placeholderText: Text(getString(.content))
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .onReceive(newsViewModel.$announcementState) { state in
            switch state {
            case .created:
                errorMessage = ""
                isActive = true
            case .error(let message):
                errorMessage = message
                showErrorAlert = true
            default:
                errorMessage = ""
            }
        }
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
        .onAppear {
            print("title: \(title) content: \(content)")
        }
    }
    
    var topBar: some View {
        HStack(alignment: .center) {
            Button(
                action: { dismiss() },
                label: { Text(getString(.cancel)) }
            )
            
           Spacer()
            
            Button(
                action: {
                    Task {
                        await newsViewModel.updateAnnouncement(id: announcement.id, title: title, content: content)
                        if newsViewModel.announcementState == .updated {
                            dismiss()
                        }
                    }
                },
                label: {
                    if content.isEmpty || title == announcement.title && content == announcement.content {
                        Text(getString(.save))
                            .fontWeight(.semibold)
                    } else {
                        Text(getString(.save))
                            .foregroundStyle(.gedPrimary)
                            .fontWeight(.semibold)
                    }
                }
            ).disabled(content.isEmpty || (title == announcement.title && content == announcement.content))
        }.padding(.vertical, 5)
    }
}

#Preview {
    NavigationStack {
        EditAnnouncementView(announcement: announcementFixture)
            .environmentObject(DependencyContainer.shared.newsViewModel)
    }
}
