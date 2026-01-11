import SwiftUI
import PhotosUI

struct AccountInformationDestination: View {
    @StateObject private var viewModel = AppMainThreadInjector.shared.resolve(AccountInformationViewModel.self)
    @State private var errorMessage: String = ""
    @State private var showErrorAlert: Bool = false
    @State private var profilePictureImage: UIImage?
    
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
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var showPhotosPicker: Bool = false
    @State private var navigationTitle = stringResource(.accountInfos)
    @State private var showDeleteAlert: Bool = false
    @State private var activeSheet: AccountInformationViewSheet?
    
    var body: some View {
        VStack(spacing: DimensResource.mediumPadding) {
            AccountInformationPicture(
                url: user.profilePictureUrl,
                image: profilePictureImage,
                onClick: {
                    if profilePictureImage == nil {
                        activeSheet = .accountInformation
                    } else {
                        showPhotosPicker = true
                    }
                },
                scale: 1.8
            )
            
            UserInformationItems(user: user)
        }
        .loading(loading)
        .task(id: selectedItem) {
            if let data = try? await selectedItem?.loadTransferable(type: Data.self) {
                if let image = UIImage(data: data) {
                    onScreenStateChange(.edit)
                    profilePictureImage = image
                }
            }
        }
        .onChange(of: screenState) { newState in
            if newState == .read {
                profilePictureImage = nil
                selectedItem = nil
                navigationTitle = stringResource(.accountInfos)
            } else {
                navigationTitle = stringResource(.editProfile)
            }
        }
        .padding(.horizontal)
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedItem, matching: .images)
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(screenState == .edit)
        .sheet(item: $activeSheet) {
            switch $0 {
                case .accountInformation:
                    SheetContainer(fraction: DimensResource.sheetFraction(itemCount: user.profilePictureUrl == nil ? 1 : 2)) {
                        SheetItem(
                            icon: Image(systemName: "photo"),
                            text: stringResource(.newProfilePicture),
                            onClick: {
                                activeSheet = nil
                                showPhotosPicker = true
                            }
                        )
                        
                        if user.profilePictureUrl != nil {
                            SheetItem(
                                icon: Image(systemName: "trash"),
                                text: stringResource(.delete),
                                onClick: {
                                    activeSheet = nil
                                    showDeleteAlert = true
                                }
                            )
                            .foregroundStyle(.red)
                        }
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
                        selectedItem = nil
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

private struct AccountInformationPicture: View {
    let url: String?
    let image: UIImage?
    let onClick: () -> Void
    let scale: CGFloat
    
    var body: some View {
        if let image {
            Button(action: onClick) {
                ProfilePictureImage(
                    image: Image(uiImage: image),
                    scale: 1.8
                )
                .clipShape(.circle)
            }
            .contentShape(.circle)
            .buttonStyle(.plain)
        } else {
            ZStack(alignment: .bottomTrailing) {
                Button(action: onClick) {
                    ProfilePicture(url: url, scale: scale)
                        .clipShape(.circle)
                }
                .contentShape(.circle)
                .buttonStyle(.plain)
                
                ZStack {
                    Circle()
                        .fill(.gedPrimary)
                        .frame(width: 30 * scale, height: 30 * scale)
                    
                    Image(systemName: "pencil")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15 * scale, height: 15 * scale)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

private enum AccountInformationViewSheet: Identifiable {
    case accountInformation
    
    var id: Int {
        switch self {
            case .accountInformation: 0
        }
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
            onDeleteProfilePictureClick: {}
        )
        .background(.profileSectionBackground)
    }
    .environment(\.managedObjectContext, GedDatabaseContainer.preview.container.viewContext)
}
