import SwiftUI
import _PhotosUI_SwiftUI

struct UserDestination: View {
    private let user: User
    
    @StateObject private var viewModel = CommonInjection.shared.resolve(UserViewModel.self)
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    @State private var profilePictureImage: UIImage? = nil
    
    init(user: User) {
        self.user = user
        _viewModel = StateObject(wrappedValue: CommonInjection.shared.resolve(UserViewModel.self, arguments: user.id)!)
    }
    
    var body: some View {
        if let currentUser = viewModel.uiState.currentUser {
            UserView(
                user: user,
                currentUser: currentUser,
                loading: viewModel.uiState.loading,
                isUserBlocked: viewModel.uiState.userBlocked,
                onReportClick: viewModel.reportUser,
                onBlockUserClick: viewModel.blockUser,
                onUnblockUserClick: viewModel.unblockUser
            )
            .onReceive(viewModel.$event) { event in
                if let errorEvent = event as? ErrorEvent {
                    errorMessage = errorEvent.message
                    showErrorAlert = true
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
        } else {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }
}

private struct UserView: View {
    let user: User
    let currentUser: User
    let loading: Bool
    let isUserBlocked: Bool
    let onReportClick: (UserReport) -> Void
    let onBlockUserClick: (String) -> Void
    let onUnblockUserClick: (String) -> Void
    
    @State private var showUserBottomSheet: Bool = false
    @State private var showReportBottomSheet: Bool = false
    @State private var showBlockAlert: Bool = false
    @State private var showUnblockAlert: Bool = false

    var body: some View {
        ZStack {
            VStack(spacing: GedSpacing.medium) {
                ProfilePicture(
                    url: user.profilePictureUrl,
                    scale: 1.6
                )
                
                UserInformationItems(user: user)
            }
        }
        .loading(loading)
        .navigationTitle(user.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showUserBottomSheet) {
            UserBottomSheet(
                isUserBlocked: isUserBlocked,
                onReportClick: {
                    showUserBottomSheet = false
                    showReportBottomSheet = true
                },
                onBlockClick: {
                    showUserBottomSheet = false
                    showBlockAlert = true
                },
                onUnblockClick: {
                    showUserBottomSheet = false
                    showUnblockAlert = true
                }
            )
        }
        .sheet(isPresented: $showReportBottomSheet) {
            ReportBottomSheet(
                items: UserReport.Reason.allCases,
                fraction: 0.26,
                onReportClick: { reason in
                    showReportBottomSheet = false
                    
                    onReportClick(
                        UserReport(
                            userId: user.id,
                            userInfo: UserReport.UserInfo(
                                fullName: user.fullName,
                                email: user.email
                            ),
                            reporterInfo: UserReport.UserInfo(
                                fullName: currentUser.fullName,
                                email: currentUser.email
                            ),
                            reason: reason
                        )
                    )
                }
            )
        }
        .toolbar {
            if user.id != currentUser.id {
                ToolbarItem(placement: .navigationBarTrailing) {
                    OptionButton(action: { showUserBottomSheet = true } )
                }
            }
        }
        .alert(
            getString(.blockUserAlertTitle),
            isPresented: $showBlockAlert
        ) {
            Button(
                getString(.cancel),
                role: .cancel,
                action: { showBlockAlert = false }
            )
            Button(getString(.block)) {
                onBlockUserClick(user.id)
            }
        } message: {
            Text(getString(.blockUserAlertMessage))
        }
        .alert(
            getString(.unblockUserAlertTitle),
            isPresented: $showUnblockAlert
        ) {
            Button(
                getString(.cancel),
                role: .cancel,
                action: { showUnblockAlert = false }
            )
            Button(getString(.unblock)) {
                onUnblockUserClick(user.id)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal)
    }
}

private struct UserBottomSheet: View {
    let isUserBlocked: Bool
    let onReportClick: () -> Void
    let onBlockClick: () -> Void
    let onUnblockClick: () -> Void
    
    var body: some View {
        BottomSheetContainer(fraction: 0.16) {
            if isUserBlocked {
                ClickableTextItem(
                    icon: Image(systemName: "nosign"),
                    text: Text(getString(.unblock)),
                    onClick: onUnblockClick
                )
            } else {
                ClickableTextItem(
                    icon: Image(systemName: "nosign"),
                    text: Text(getString(.block)),
                    onClick: onBlockClick
                )
            }
            
            ClickableTextItem(
                icon: Image(systemName: "exclamationmark.bubble"),
                text: Text(getString(.report)),
                onClick: onReportClick
            )
            .foregroundColor(.error)
        }
    }
}

#Preview {
    NavigationStack {
        UserView(
            user: userFixture,
            currentUser: userFixture2,
            loading: false,
            isUserBlocked: false,
            onReportClick: { _ in },
            onBlockUserClick: { _ in },
            onUnblockUserClick: { _ in }
        )
        .background(Color.background)
    }
}
