import SwiftUI

struct CreateAnnouncementView: View {
    @EnvironmentObject private var newsViewModel: NewsViewModel
    @State private var textHeight: CGFloat = 40
    private let lineHeight: CGFloat = 24
    @State private var isActive: Bool = false
    @Environment(\.dismiss) var dismiss
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var title: String = ""
    @State private var content: String = ""
    
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
                                await newsViewModel.createAnnouncement(title: title, content: content)
                                if newsViewModel.announcementState == .created {
                                    dismiss()
                                }
                            }
                        },
                        label: {
                            if content.isEmpty {
                                Text(getString(gedString: GedString.post))
                                    .fontWeight(.semibold)
                            } else {
                                Text(getString(gedString: GedString.post))
                                    .foregroundColor(.gedPrimary)
                                    .fontWeight(.semibold)
                            }
                        }
                    ).disabled(content.isEmpty)
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
                showErrorAlert = true
            default:
                errorMessage = ""
            }
        }
        .alert(
            errorMessage,
            isPresented: $showErrorAlert
        ) {
            Button(getString(gedString: GedString.ok)) {
                showErrorAlert = false
            }
        }
    }
}

#Preview {
    NavigationView {
        CreateAnnouncementView()
            .environmentObject(DependencyContainer.shared.newsViewModel)
    }
}
