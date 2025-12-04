import SwiftUI
import _PhotosUI_SwiftUI

struct UserDestination: View {
    private let user: User
    
    @StateObject private var viewModel: UserViewModel
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    @State private var profilePictureImage: UIImage? = nil
    
    init(user: User) {
        self.user = user
        _viewModel = StateObject(wrappedValue: CommonMainThreadInjector.shared.resolve(UserViewModel.self, arguments: user.id)!)
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
                isPresented: $showErrorAlert,
                actions: {
                    Button(stringResource(.ok)) {
                        showErrorAlert = false
                    }
                }
            )
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
    private let userName: String
    
    init(
        user: User,
        currentUser: User,
        loading: Bool,
        isUserBlocked: Bool,
        onReportClick: @escaping (UserReport) -> Void,
        onBlockUserClick: @escaping (String) -> Void,
        onUnblockUserClick: @escaping (String) -> Void
    ) {
        self.user = user
        self.currentUser = currentUser
        self.loading = loading
        self.isUserBlocked = isUserBlocked
        self.onReportClick = onReportClick
        self.onBlockUserClick = onBlockUserClick
        self.onUnblockUserClick = onUnblockUserClick
        self.userName = user.state == .deleted ? stringResource(.deletedUser) : user.fullName
    }

    var body: some View {
        VStack(spacing: Dimens.mediumPadding) {
            ProfilePicture(
                url: user.profilePictureUrl,
                scale: 1.6
            )
            
            if user.state != .deleted {
                UserInformationItems(user: user)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .loading(loading)
        .navigationTitle(userName)
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
                fraction: Dimens.reportBottomSheetFraction(itemCount: UserReport.Reason.allCases.count),
                onReportClick: { reason in
                    showReportBottomSheet = false
                    
                    onReportClick(
                        UserReport(
                            userId: user.id,
                            reportedUser: UserReport.ReportedUser(
                                fullName: user.fullName,
                                email: user.email
                            ),
                            reporterInfo: UserReport.Reporter(
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
                    OptionsButton(action: { showUserBottomSheet = true } )
                }
            }
        }
        .alert(
            stringResource(.blockUserAlertTitle),
            isPresented: $showBlockAlert,
            actions: {
                Button(
                    stringResource(.cancel),
                    role: .cancel,
                    action: { showBlockAlert = false }
                )
                Button(stringResource(.block)) {
                    onBlockUserClick(user.id)
                }
            },
            message: {
                Text(stringResource(.blockUserAlertMessage))
            }
        )
        .alert(
            stringResource(.unblockUserAlertMessage),
            isPresented: $showUnblockAlert,
            actions: {
                Button(
                    stringResource(.cancel),
                    role: .cancel,
                    action: { showUnblockAlert = false }
                )
                Button(stringResource(.unblock)) {
                    onUnblockUserClick(user.id)
                }
            }
        )
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
        BottomSheetContainer(fraction: Dimens.bottomSheetFraction(itemCount: 2)) {
            if isUserBlocked {
                ClickableTextItem(
                    icon: Image(systemName: "nosign"),
                    text: Text(stringResource(.unblock)),
                    onClick: onUnblockClick
                )
            } else {
                ClickableTextItem(
                    icon: Image(systemName: "nosign"),
                    text: Text(stringResource(.block)),
                    onClick: onBlockClick
                )
            }
            
            ClickableTextItem(
                icon: Image(systemName: "exclamationmark.bubble"),
                text: Text(stringResource(.report)),
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
    }
}
