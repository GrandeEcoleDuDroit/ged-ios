import SwiftUI

struct CreateAnnouncementView: View {
    @StateObject private var createAnnouncementViewModel: CreateAnnouncementViewModel = DependencyContainer.shared.createAnnouncementViewModel
    @State private var textHeight: CGFloat = 40
    private let lineHeight: CGFloat = 24
    @State private var isActive: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading) {
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
        .navigationTitle(getString(gedString: GedString.create_announcement))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(
                    action: {
                        Task {
                            await createAnnouncementViewModel.createAnnouncement()
                            dismiss()
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
            }
        }.onReceive(createAnnouncementViewModel.$announcementState) { value in
            if case .created = value {
                isActive = true
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
