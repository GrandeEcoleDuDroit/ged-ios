import SwiftUI

struct CreateAnnouncementView: View {
    @StateObject private var createAnnouncementViewModel: CreateAnnouncementViewModel = NewsInjection.shared.resolve(CreateAnnouncementViewModel.self)
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @FocusState private var inputFieldFocused: InputField?
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var title: String = ""
    @State private var content: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            TextField(getString(.title), text: $title, axis: .vertical)
                .font(.title2)
                .fontWeight(.semibold)
                .focused($inputFieldFocused, equals: InputField.title)
                .onChange(of: title) {
                    title = String($0.prefix(150))
                }
            
            TextField(getString(.content), text: $content, axis: .vertical)
                .font(.bodyLarge)
                .lineSpacing(5)
                .focused($inputFieldFocused, equals: InputField.content)
        }
        .navigationTitle(getString(.newAnnouncement))
        .navigationBarTitleDisplayMode(.inline)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding()
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
                        createAnnouncementViewModel.createAnnouncement(title: title, content: content)
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
                )
                .disabled(content.isEmpty)
            }
        }
        .onReceive(createAnnouncementViewModel.$announcementState) { state in
            switch state {
                case .created:
                    navigationCoordinator.pop()
                case .error(let message):
                    errorMessage = message
                    showErrorAlert = true
                default:
                    errorMessage = ""
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
    NavigationStack {
        CreateAnnouncementView()
            .environmentObject(NavigationCoordinator())
    }
}
