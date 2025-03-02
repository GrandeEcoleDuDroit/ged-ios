import SwiftUI

struct CreateAnnouncementView: View {
    @StateObject private var createAnnouncementViewModel: CreateAnnouncementViewModel = NewsInjection.shared.resolve(CreateAnnouncementViewModel.self)
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @FocusState private var inputFieldFocused: InputField?
    @State private var showToast: Bool = false
    @State private var toastMessage: String = ""
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
        .toast(isPresented: $showToast, message: toastMessage)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(
                    action: {
                        do {
                            try createAnnouncementViewModel.createAnnouncement(title: title, content: content)
                            navigationCoordinator.pop()
                        } catch UserError.currentUserNotFound {
                            toastMessage = getString(.userNotFoundError)
                            showToast = true
                        } catch {
                            toastMessage = error.localizedDescription
                            showToast = true
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
                )
                .disabled(content.isEmpty)
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
