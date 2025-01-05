import SwiftUI

struct EditAnnouncementView: View {
    @EnvironmentObject private var newsViewModel: NewsViewModel
    @FocusState private var inputFieldFocused: InputField?
    @State private var isActive: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var title: String
    @State private var content: String
    
    private let announcement: Announcement
    private let onCancelClick: () -> Void
    private let onSaveClick: (String, String) -> Void

    init(
        announcement: Announcement,
        onCancelClick: @escaping () -> Void,
        onSaveClick: @escaping (String, String) -> Void
    ) {
        self.announcement = announcement
        self.onCancelClick = onCancelClick
        self.onSaveClick = onSaveClick
        self.title =  announcement.title ?? ""
        self.content = announcement.content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: GedSpacing.medium) {
            TextField(getString(.title), text: $title, axis: .vertical)
                .font(.title2)
                .fontWeight(.semibold)
                .focused($inputFieldFocused, equals: InputField.title)
            
            TextField(getString(.content), text: $content, axis: .vertical)
                .font(.bodyLarge)
                .lineSpacing(5)
                .focused($inputFieldFocused, equals: InputField.content)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
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
        .navigationTitle(getString(.edit))
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
                    action: { onSaveClick(title, content) },
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
                )
                .disabled(content.isEmpty || (title == announcement.title && content == announcement.content))
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
    let navigationCoordinator = StateObject(wrappedValue: CommonDependencyInjectionContainer.shared.resolve(NavigationCoordinator.self))
    let mockNewsViewModel = NewsDependencyInjectionContainer.shared.resolveWithMock().resolve(NewsViewModel.self)!
    
    NavigationStack(path: navigationCoordinator.projectedValue.path) {
        EditAnnouncementView(
            announcement: announcementFixture,
            onCancelClick: {},
            onSaveClick: { _, _ in }
        )
        .environmentObject(mockNewsViewModel)
    }
}
