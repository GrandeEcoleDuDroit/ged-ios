import SwiftUI
import _PhotosUI_SwiftUI

struct AccountInformationDestination: View {
    @StateObject private var viewModel = AppMainThreadInjector.shared.resolve(AccountInformationViewModel.self)
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
    @State private var navigationTitle = stringResource(.accountInfos)
    @State private var showDeleteAlert: Bool = false
    @State private var bottomSheetItemCount: Int
    
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
        
        self.bottomSheetItemCount = user.profilePictureUrl != nil ? 2 : 1
    }

    var body: some View {
        ZStack {
            VStack(spacing: Dimens.mediumPadding) {
                if let profilePictureImage {
                    ClickableProfilePictureImage(
                        image: profilePictureImage,
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
            bottomSheetItemCount = profilePictureUrl != nil ? 2 : 1
        }
        .onChange(of: screenState) { newState in
            if newState == .read {
                profilePictureImage = nil
                selectedPhoto = nil
                navigationTitle = stringResource(.accountInfos)
            } else {
                navigationTitle = stringResource(.editProfile)
            }
        }
        .padding(.horizontal)
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhoto, matching: .images)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(screenState == .edit)
        .sheet(isPresented: $showBottomSheet) {
            BottomSheetContainer(fraction: Dimens.bottomSheetFraction(itemCount: bottomSheetItemCount)) {
                ClickableTextItem(
                    icon: Image(systemName: "photo"),
                    text: Text(stringResource(.newProfilePicture))
                ) {
                    showPhotosPicker = true
                    showBottomSheet = false
                }
                
                if user.profilePictureUrl != nil {
                    ClickableTextItem(
                        icon: Image(systemName: "trash"),
                        text: Text(stringResource(.delete))
                    ) {
                        showBottomSheet = false
                        showDeleteAlert = true
                    }
                    .foregroundStyle(.red)
                }
            }
        }
        .alert(
            stringResource(.deleteProfilePictureAlertMessage),
            isPresented: $showDeleteAlert,
            actions: {
                Button(stringResource(.cancel), role: .cancel) {
                    showDeleteAlert = false
                }
                Button(stringResource(.delete), role: .destructive) {
                    onDeleteProfilePictureClick()
                    showDeleteAlert = false
                }
            }
        )
        .toolbar {
            if screenState == .edit {
                ToolbarItem(placement: .topBarLeading) {
                    Button(stringResource(.cancel)) {
                        onScreenStateChange(.read)
                        profilePictureImage = nil
                        selectedPhoto = nil
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: {
                            if let profilePictureImage {
                                onSaveProfilePictureClick(profilePictureImage.jpegData(compressionQuality: 0.8))
                            }
                        },
                        label: {
                            Text(stringResource(.save))
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
        .background(.profileSectionBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
