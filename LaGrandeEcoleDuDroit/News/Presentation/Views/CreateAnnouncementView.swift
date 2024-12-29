import SwiftUI

struct CreateAnnouncementView: View {
    @EnvironmentObject private var newsViewModel: NewsViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var title: String = ""
    @State private var content: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                TextEditor(text: $title)
                    .font(.system(size: 22, weight: .semibold))
                    .overlay {
                        if title.isEmpty {
                            Text(getString(.title))
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
                            Text(getString(.content))
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
        .navigationTitle(getString(.newAnnouncement))
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
        .onReceive(newsViewModel.$announcementState) { state in
            switch state {
            case .created:
                errorMessage = ""
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
            Button(getString(.ok)) {
                showErrorAlert = false
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
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
                            Text(getString(.post))
                                .fontWeight(.semibold)
                        } else {
                            Text(getString(.post))
                                .foregroundColor(.gedPrimary)
                                .fontWeight(.semibold)
                        }
                    }
                ).disabled(content.isEmpty)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CreateAnnouncementView()
            .environmentObject(DependencyContainer.shared.newsViewModel)
    }
}
