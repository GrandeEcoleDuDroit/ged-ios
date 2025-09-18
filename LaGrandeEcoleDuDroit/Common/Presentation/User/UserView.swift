import SwiftUI
import _PhotosUI_SwiftUI

struct UserDestination: View {
    let user: User
    
    @StateObject private var viewModel = CommonInjection.shared.resolve(UserViewModel.self)
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    @State private var profilePictureImage: UIImage? = nil
    
    var body: some View {
        if let currentUser = viewModel.uiState.currentUser {
            UserView(
                user: user,
                currentUser: currentUser,
                loading: viewModel.uiState.loading,
                onReportClick: viewModel.reportUser
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
    let onReportClick: (UserReport) -> Void
    
    @State private var showUserBottomSheet: Bool = false
    @State private var showReportBottomSheet: Bool = false

    var body: some View {
        ZStack {
            VStack {
                ProfilePicture(
                    url: user.profilePictureUrl,
                    scale: 1.6
                )
                
                UserInformationItems(user: user)
            }
            .loading(loading)
        }
        .navigationTitle(user.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showUserBottomSheet) {
            UserBottomSheet(
                onReportClick: {
                    showUserBottomSheet = false
                    showReportBottomSheet = true
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
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

private struct UserBottomSheet: View {
    let onReportClick: () -> Void
    
    var body: some View {
        BottomSheetContainer(fraction: 0.1) {
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
            onReportClick: { _ in }
        )
        .background(Color.background)
    }
}
