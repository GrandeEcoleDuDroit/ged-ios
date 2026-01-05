import SwiftUI
import PhotosUI

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
                blockedUser: viewModel.uiState.blockedUser,
                onReportUserClick: viewModel.reportUser,
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
    let blockedUser: Bool
    let onReportUserClick: (UserReport) -> Void
    let onBlockUserClick: (String) -> Void
    let onUnblockUserClick: (String) -> Void
    
    @State private var activeSheet: UserViewSheet?
    @State private var showBlockAlert: Bool = false
    @State private var showUnblockAlert: Bool = false
    
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
        .navigationTitle(user.displayedName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $activeSheet) {
            switch $0 {
                case .user:
                    UserSheet(
                        blockedUser: blockedUser,
                        onReportUserClick: {
                            activeSheet = .userReport
                        },
                        onBlockUserClick: {
                            activeSheet = nil
                            showBlockAlert = true
                        },
                        onUnblockUserClick: {
                            activeSheet = nil
                            showUnblockAlert = true
                        }
                    )
                    
                case .userReport:
                    ReportSheet(
                        items: UserReport.Reason.allCases,
                        fraction: Dimens.reportSheetFraction(itemCount: UserReport.Reason.allCases.count),
                        onReportClick: { reason in
                            activeSheet = nil
                            onReportUserClick(
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
        }
        .toolbar {
            if user.id != currentUser.id {
                ToolbarItem(placement: .navigationBarTrailing) {
                    OptionsButton(action: { activeSheet = .user } )
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

private struct UserSheet: View {
    let blockedUser: Bool
    let onReportUserClick: () -> Void
    let onBlockUserClick: () -> Void
    let onUnblockUserClick: () -> Void
    
    var body: some View {
        SheetContainer(fraction: Dimens.sheetFraction(itemCount: 2)) {
            if blockedUser {
                SheetItem(
                    icon: Image(systemName: "nosign"),
                    text: stringResource(.unblock),
                    onClick: onUnblockUserClick
                )
            } else {
                SheetItem(
                    icon: Image(systemName: "nosign"),
                    text: stringResource(.block),
                    onClick: onBlockUserClick
                )
            }
            
            SheetItem(
                icon: Image(systemName: "exclamationmark.bubble"),
                text: stringResource(.report),
                onClick: onReportUserClick
            )
            .foregroundColor(.error)
        }
    }
}

private enum UserViewSheet: Identifiable {
    case user
    case userReport
    
    var id: Int {
        switch self {
            case .user: 0
            case .userReport: 1
        }
    }
}

#Preview {
    NavigationStack {
        UserView(
            user: userFixture,
            currentUser: userFixture2,
            loading: false,
            blockedUser: false,
            onReportUserClick: { _ in },
            onBlockUserClick: { _ in },
            onUnblockUserClick: { _ in }
        )
    }
}
