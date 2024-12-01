import SwiftUI

struct EditAnnouncementView: View {
    @EnvironmentObject private var newsViewModel: NewsViewModel
    private let announcement: Announcement
    @State private var textHeight: CGFloat = 40
    private let lineHeight: CGFloat = 24
    @State private var isActive: Bool = false
    @Environment(\.dismiss) var dismiss
    @State private var showErrorDialog: Bool = false
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
                HStack(alignment: .center) {
                    Button(
                        action: { dismiss() },
                        label: { Text(getString(gedString: GedString.cancel)) }
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
                                Text(getString(gedString: GedString.save))
                                    .fontWeight(.semibold)
                            } else {
                                Text(getString(gedString: GedString.save))
                                    .foregroundColor(.gedPrimary)
                                    .fontWeight(.semibold)
                            }
                        }
                    ).disabled(content.isEmpty || (title == announcement.title && content == announcement.content))
                }.padding(.vertical, 5)
                
                TextEditor(text: $title)
                    .font(.system(size: 22, weight: .semibold))
                    .overlay {
                        if title.isEmpty {
                            Text(getString(gedString: GedString.title))
                                .foregroundColor(.gray)
                                .padding(.top, 10)
                                .padding(.leading, 6)
                                .font(.system(size: 22, weight: .semibold))
                                .frame(
                                    maxWidth: .infinity,
                                    maxHeight: .infinity,
                                    alignment: .topLeading
                                )
                        }
                    }
                    .frame(
                        minHeight: geometry.size.height / 14,
                        maxHeight: geometry.size.height / 6
                    )
                    .fixedSize(horizontal: false, vertical: true)
                    .background(Color.blue)
                
                TextEditor(text: $content)
                    .overlay {
                        if content.isEmpty {
                            Text(getString(gedString: GedString.content))
                                .foregroundColor(.gray)
                                .padding(.top, 10)
                                .padding(.leading, 6)
                                .font(.body)
                                .frame(maxWidth: .infinity, maxHeight: .infinity,alignment: .topLeading)
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
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
                showErrorDialog = true
            default:
                errorMessage = ""
            }
        }
        .alert(
            "",
            isPresented: $showErrorDialog,
            presenting: ""
        ) { data in
            Button(getString(gedString: GedString.ok)) {
                showErrorDialog = false
            }
        } message: { data in
            Text(errorMessage)
        }
    }
}

#Preview {
    NavigationView {
        EditAnnouncementView(announcement: announcementFixture)
            .environmentObject(DependencyContainer.shared.newsViewModel)
    }
}
