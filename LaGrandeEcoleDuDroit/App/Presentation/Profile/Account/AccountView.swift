import SwiftUI
import _PhotosUI_SwiftUI

struct AccountDestination: View {
    @StateObject private var viewModel = MainInjection.shared.resolve(AccountViewModel.self)
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    @State private var profilePictureData: Data? = nil
    
    var body: some View {
        AccountView(
            user: viewModel.uiState.user,
            loading: viewModel.uiState.loading,
            screenState: viewModel.uiState.screenState,
            profilePictureData: $profilePictureData,
            onScreenStateChange: viewModel.onScreenStateChange,
            onSaveProfilePictureClick: viewModel.updateProfilePicture,
            onDeleteProfilePictureClick: viewModel.deleteProfilePicture
        )
        .onReceive(viewModel.$event) { event in
            if let errorEvent = event as? ErrorEvent {
                errorMessage = errorEvent.message
                showErrorAlert = true
            } else if event is SuccessEvent {
                profilePictureData = nil
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
    }
}

private struct AccountView: View {
    let user: User?
    let loading: Bool
    let screenState: AccountScreenState
    @Binding var profilePictureData: Data?
    let onScreenStateChange: (AccountScreenState) -> Void
    let onSaveProfilePictureClick: (Data?) -> Void
    let onDeleteProfilePictureClick: () -> Void
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showBottomSheet: Bool = false
    @State private var showPhotosPicker: Bool = false
    @State private var isBottomSheetItemClicked: Bool = false
    @State private var navigationTitle = getString(.accountInfos)
    @State private var showDeleteAlert: Bool = false
    @State private var bottomSheetItemSize: CGFloat = 0.1

    var body: some View {
        ZStack {
            if let user = user {
                VStack {
                    if let profilePictureData = profilePictureData {
                        ClickableProfilePictureImage(
                            data: profilePictureData,
                            onClick: { showPhotosPicker = true },
                            scale: 1.6
                        )
                    } else {
                        AccountImage(
                            imagePhase: user.imagePhase,
                            onClick: { showBottomSheet = true },
                            scale: 1.6
                        )
                    }
                    
                    AccountInfoItems(user: user)
                }
                .loading(loading)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .task(id: selectedPhoto) {
            if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                onScreenStateChange(.edit)
                profilePictureData = data
            }
        }
        .onChange(of: user?.profilePictureUrl) { profilePictureUrl in
            bottomSheetItemSize = profilePictureUrl != nil ? 0.18 : 0.1
        }
        .onChange(of: screenState) { newState in
            if newState == .read {
                profilePictureData = nil
                selectedPhoto = nil
                navigationTitle = getString(.accountInfos)
            } else {
                navigationTitle = getString(.editProfile)
            }
        }
        .onChange(of: bottomSheetItemSize) { _ in }
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhoto, matching: .images)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(screenState == .edit)
        .sheet(isPresented: $showBottomSheet) {
            BottomSheetContainer(fraction: bottomSheetItemSize) {
                ClickableItemWithIcon(
                    icon: Image(systemName: "photo.fill"),
                    text: Text(getString(.newProfilePicture))
                ) {
                    showPhotosPicker = true
                    showBottomSheet = false
                }
                .font(.bodyLarge)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if user?.profilePictureUrl != nil {
                    ClickableItemWithIcon(
                        icon: Image(systemName: "trash"),
                        text: Text(getString(.delete))
                    ) {
                        showBottomSheet = false
                        showDeleteAlert = true
                    }
                    .font(.bodyLarge)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .alert(
            getString(.deleteProfilePictureAlertMessage),
            isPresented: $showDeleteAlert
        ) {
            Button(getString(.cancel), role: .cancel) {
                showDeleteAlert = false
            }
            Button(getString(.delete), role: .destructive) {
                onDeleteProfilePictureClick()
                showDeleteAlert = false
            }
        }
        .toolbar {
            if screenState == .edit {
                ToolbarItem(placement: .topBarLeading) {
                    Button(getString(.cancel)) {
                        onScreenStateChange(.read)
                        profilePictureData = nil
                        selectedPhoto = nil
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: {
                            if let profilePictureData = profilePictureData {
                                onSaveProfilePictureClick(profilePictureData)
                            }
                        },
                        label: {
                            if loading {
                                Text(getString(.save))
                                    .fontWeight(.semibold)
                            } else {
                                Text(getString(.save))
                                    .foregroundStyle(.gedPrimary)
                                    .fontWeight(.semibold)
                            }
                        }
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .disabled(loading)
    }
}

private struct AccountInfoItems: View {
    private var user: User
    
    init(user: User){
        self.user = user
    }
    
    var body: some View {
        VStack(spacing: GedSpacing.medium) {
            AccountInfoItem(title: getString(.lastName), value: user.lastName)
            AccountInfoItem(title: getString(.firstName), value: user.firstName)
            AccountInfoItem(title: getString(.email), value: user.email)
            AccountInfoItem(title: getString(.schoolLevel), value: user.schoolLevel.rawValue)
            
            if user.isMember {
                HStack {
                    Text(getString(.member))
                        .font(.callout)
                        .bold()
                        .foregroundColor(.textPreview)
                    
                    Image(systemName: "star.fill")
                        .foregroundStyle(.gold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal)
        .padding(.top, GedSpacing.smallMedium)
    }
}

#Preview {
    NavigationStack {
        AccountView(
            user: userFixture,
            loading: false,
            screenState: .read,
            profilePictureData: .constant(nil),
            onScreenStateChange: { _ in },
            onSaveProfilePictureClick: { _ in },
            onDeleteProfilePictureClick: {  }
        )
        .background(Color.background)
    }
}
