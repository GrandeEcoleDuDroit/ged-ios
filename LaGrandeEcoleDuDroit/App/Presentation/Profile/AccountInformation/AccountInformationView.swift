import SwiftUI
import _PhotosUI_SwiftUI

struct AccountInformationDestination: View {
    @StateObject private var viewModel = MainInjection.shared.resolve(AccountInformationViewModel.self)
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    @State private var profilePictureImage: UIImage? = nil
    
    var body: some View {
        if let user = viewModel.uiState.user {
            AccountInformationView(
                user: user,
                loading: viewModel.uiState.loading,
                screenState: viewModel.uiState.screenState,
                profilePictureImage: $profilePictureImage,
                onScreenStateChange: viewModel.onScreenStateChange,
                onSaveProfilePictureClick: viewModel.updateProfilePicture,
                onDeleteProfilePictureClick: viewModel.deleteProfilePicture
            )
            .onReceive(viewModel.$event) { event in
                if let errorEvent = event as? ErrorEvent {
                    errorMessage = errorEvent.message
                    showErrorAlert = true
                } else if event is SuccessEvent {
                    profilePictureImage = nil
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

private struct AccountInformationView: View {
    let user: User
    let loading: Bool
    let screenState: AccountInformationViewModel.ScreenState
    @Binding var profilePictureImage: UIImage?
    let onScreenStateChange: (AccountInformationViewModel.ScreenState) -> Void
    let onSaveProfilePictureClick: (Data?) -> Void
    let onDeleteProfilePictureClick: () -> Void
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showBottomSheet: Bool = false
    @State private var showPhotosPicker: Bool = false
    @State private var isBottomSheetItemClicked: Bool = false
    @State private var navigationTitle = getString(.accountInfos)
    @State private var showDeleteAlert: Bool = false
    @State private var bottomSheetItemSize: CGFloat
    
    init(
        user: User,
        loading: Bool,
        screenState: AccountInformationViewModel.ScreenState,
        profilePictureImage: Binding<UIImage?>,
        onScreenStateChange: @escaping (AccountInformationViewModel.ScreenState) -> Void,
        onSaveProfilePictureClick: @escaping (Data?) -> Void,
        onDeleteProfilePictureClick: @escaping () -> Void
    ) {
        self.user = user
        self.loading = loading
        self.screenState = screenState
        self._profilePictureImage = profilePictureImage
        self.onScreenStateChange = onScreenStateChange
        self.onSaveProfilePictureClick = onSaveProfilePictureClick
        self.onDeleteProfilePictureClick = onDeleteProfilePictureClick
        
        self.bottomSheetItemSize = user.profilePictureUrl != nil ? 0.16 : 0.1
    }

    var body: some View {
        ZStack {
            VStack(spacing: GedSpacing.medium) {
                if let image = profilePictureImage {
                    ClickableProfilePictureImage(
                        image: image,
                        onClick: { showPhotosPicker = true },
                        scale: 1.6
                    )
                } else {
                    AccountImage(
                        url: user.profilePictureUrl,
                        onClick: { showBottomSheet = true },
                        scale: 1.6
                    )
                }
                
                UserInformationItems(user: user)
            }
        }
        .loading(loading)
        .task(id: selectedPhoto) {
            if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                if let image = UIImage(data: data) {
                    onScreenStateChange(.edit)
                    profilePictureImage = image
                }
            }
        }
        .onChange(of: user.profilePictureUrl) { profilePictureUrl in
            bottomSheetItemSize = profilePictureUrl != nil ? 0.18 : 0.1
        }
        .onChange(of: screenState) { newState in
            if newState == .read {
                profilePictureImage = nil
                selectedPhoto = nil
                navigationTitle = getString(.accountInfos)
            } else {
                navigationTitle = getString(.editProfile)
            }
        }
        .padding(.horizontal)
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhoto, matching: .images)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(screenState == .edit)
        .sheet(isPresented: $showBottomSheet) {
            BottomSheetContainer(fraction: bottomSheetItemSize) {
                ClickableTextItem(
                    icon: Image(systemName: "photo"),
                    text: Text(getString(.newProfilePicture))
                ) {
                    showPhotosPicker = true
                    showBottomSheet = false
                }
                
                if user.profilePictureUrl != nil {
                    ClickableTextItem(
                        icon: Image(systemName: "trash"),
                        text: Text(getString(.delete))
                    ) {
                        showBottomSheet = false
                        showDeleteAlert = true
                    }
                    .foregroundStyle(.red)
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
                        profilePictureImage = nil
                        selectedPhoto = nil
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: {
                            if let image = profilePictureImage {
                                onSaveProfilePictureClick(image.jpegData(compressionQuality: 0.8))
                            }
                        },
                        label: {
                            Text(getString(.save))
                                .bold()
                                .foregroundStyle(.gedPrimary)
                        }
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .disabled(loading)
    }
}

#Preview {
    NavigationStack {
        AccountInformationView(
            user: userFixture,
            loading: false,
            screenState: .read,
            profilePictureImage: .constant(nil),
            onScreenStateChange: { _ in },
            onSaveProfilePictureClick: { _ in },
            onDeleteProfilePictureClick: {  }
        )
        .background(Color.background)
    }
}
