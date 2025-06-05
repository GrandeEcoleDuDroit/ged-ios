import SwiftUI
import _PhotosUI_SwiftUI

struct AccountDestination: View {
    @StateObject private var viewModel = ProfileInjection.shared.resolve(AccountViewModel.self)
    
    var body: some View {
        AccountView(
            user: viewModel.uiState.user,
            loading: viewModel.uiState.loading,
            screenState: viewModel.uiState.screenState,
            onScreenStateChange: viewModel.onScreenStateChange,
            onSaveProfilePictureClick: viewModel.updateProfilePicture
        )
    }
}

private struct AccountView: View {
    let user: User?
    let loading: Bool
    let screenState: AccountScreenState
    let onScreenStateChange: (AccountScreenState) -> Void
    let onSaveProfilePictureClick: (Data?) -> Void
    
    @State private var profilePictureImage: UIImage?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showBottomSheet: Bool = false
    @State private var showPhotosPicker: Bool = false
    @State private var isBottomSheetItemClicked: Bool = false
    @State private var navigationTitle = getString(.accountInfos)
    var body: some View {
        ZStack {
            if let user = user {
                VStack {
                    if let image = profilePictureImage {
                        ClickableProfilePictureImage(
                            image: image,
                            onClick: { showPhotosPicker = true },
                            scale: 1.6
                        )
                    } else {
                        ProfilePictureEdit(
                            url: user.profilePictureFileName,
                            onClick: { showBottomSheet = true },
                            scale: 1.6
                        )
                    }
                    
                    AccountInfoItems(user: user)
                }
                
                if loading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.lightGrey.opacity(0.4))
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .task(id: selectedPhoto) {
            if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                if let image = UIImage(data: data) {
                    onScreenStateChange(.edit)
                    profilePictureImage = image
                }
            }
        }
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhoto, matching: .images)
        .navigationTitle(screenState == .edit ? getString(.editProfile) : getString(.accountInfos))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(screenState == .edit)
        .sheet(isPresented: $showBottomSheet) {
            ItemWithIcon(
                icon: Image(systemName: "photo.fill"),
                text: Text(getString(.newProfilePicture))
            )
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .presentationDetents([.fraction(0.10)])
            .onClick(isClicked: $isBottomSheetItemClicked) {
                showPhotosPicker = true
                showBottomSheet = false
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
            onScreenStateChange: {_ in},
            onSaveProfilePictureClick: {_ in}
        )
    }
}
