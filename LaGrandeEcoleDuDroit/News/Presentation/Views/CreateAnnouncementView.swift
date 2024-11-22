import SwiftUI

struct CreateAnnouncementView: View {
    @StateObject private var createAnnouncementViewModel: CreateAnnouncementViewModel = DependencyContainer.shared.createAnnouncementViewModel
    @State private var textHeight: CGFloat = 40
    private let lineHeight: CGFloat = 24
    @State private var isActive: Bool = false
    @Environment(\.dismiss) var dismiss
    @State private var showErrorDialog: Bool = false
    @State private var errorMessage: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
                HStack(alignment: .center) {
                    Button(
                        action: { dismiss() },
                        label: { Text(getString(gedString: GedString.cancel))
                                .foregroundStyle(.black)
                        }
                    )
                    
                    Text(getString(gedString: GedString.new_announcement))
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Button(
                        action: {
                            Task {
                                await createAnnouncementViewModel.createAnnouncement()
                                if createAnnouncementViewModel.announcementState == .created {
                                    dismiss()
                                }
                            }
                        },
                        label: {
                            if createAnnouncementViewModel.content.isEmpty {
                                Text(getString(gedString: GedString.post))
                                    .fontWeight(.semibold)
                            } else {
                                Text(getString(gedString: GedString.post))
                                    .foregroundColor(.gedPrimary)
                                    .fontWeight(.semibold)
                            }
                        }
                    ).disabled(createAnnouncementViewModel.content.isEmpty)
                }.padding(.vertical, 5)
                
                TextEditor(text: $createAnnouncementViewModel.title)
                    .font(.system(size: 22, weight: .semibold))
                    .overlay {
                        if createAnnouncementViewModel.title.isEmpty {
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
                
                TextEditor(text: $createAnnouncementViewModel.content)
                    .overlay {
                        if createAnnouncementViewModel.content.isEmpty {
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
        .onReceive(createAnnouncementViewModel.$announcementState) { state in
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
        CreateAnnouncementView()
            .environmentObject(DependencyContainer.shared.newsViewModel)
    }
}
