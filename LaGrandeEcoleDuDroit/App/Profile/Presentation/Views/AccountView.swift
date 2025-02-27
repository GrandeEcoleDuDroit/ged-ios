import SwiftUI
import _PhotosUI_SwiftUI

struct AccountView: View {
    @StateObject private var accountViewModel = ProfileInjection.shared.resolve(AccountViewModel.self)
    @EnvironmentObject private var navigationCoordinator: NavigationCoordinator
    @State private var profilePictureImage: UIImage?
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var editMode: Bool = false
    @State private var showBottomSheet: Bool = false
    @State private var showPhotosPicker: Bool = false
    @State private var isBottomSheetItemClicked: Bool = false
    @State private var isLoading: Bool = false
    @State private var snackBarType: SnackBarType = .info()
    @State private var showSnackBar: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                if let image = profilePictureImage {
                    ClickableProfilePictureImage(
                        image: image,
                        onClick: { showPhotosPicker = true },
                        scale: 1.6
                    )
                } else {
                    ProfilePictureEdit(
                        url: accountViewModel.currentUser?.profilePictureUrl,
                        onClick: { showBottomSheet = true },
                        scale: 1.6
                    )
                }
                
                if let currentUser = accountViewModel.currentUser {
                    InfosSection(user: currentUser)
                }
            }
            
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.lightGrey.opacity(0.4))
            }
            
            if showSnackBar {
                switch snackBarType {
                    case .success(let message):
                        SuccesSnackbar(message)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .padding(.horizontal)
                    case .error(let message):
                        ErrorSnackbar(message)
                            .frame(maxHeight: .infinity, alignment: .bottom)
                            .padding(.horizontal)
                    default : EmptyView()
                }
            }
        }
        .task(id: selectedPhoto) {
            if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                if let image = UIImage(data: data) {
                    editMode = true
                    profilePictureImage = image
                }
            }
        }
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhoto, matching: .images)
        .navigationTitle(editMode ? getString(.editProfile) : getString(.accountInfos))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(editMode)
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
        .onReceive(accountViewModel.$screenState) { state in
            switch state {
                case .loading:
                    isLoading = true
                case .error(let message):
                    snackBarType = .error(message)
                    isLoading = false
                    withAnimation {
                        showSnackBar = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showSnackBar = false
                        }
                    }
                    accountViewModel.updateScreenState(.initial)
                case .success:
                    snackBarType = .success(getString(.profilePictureUpdated))
                    isLoading = false
                    editMode = false
                    withAnimation {
                        showSnackBar = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showSnackBar = false
                        }
                    }
                    accountViewModel.updateScreenState(.initial)
                default:
                    isLoading = false
            }
        }
        .toolbar {
            if editMode {
                ToolbarItem(placement: .topBarLeading) {
                    Button(getString(.cancel)) {
                        editMode = false
                        profilePictureImage = nil
                        selectedPhoto = nil
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(
                        action: {
                            if let image = profilePictureImage {
                                accountViewModel.updateProfilePicture(imageData: image.jpegData(compressionQuality: 0.8))
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
    }
}

private struct InfosSection: View {
    private var user: User
    
    init(
        user: User
    ) {
        self.user = user
    }
    
    var body: some View {
        VStack(spacing: GedSpacing.medium) {
            AccountInfoItem(title: getString(.lastName), value: user.lastName)
            AccountInfoItem(title: getString(.firstName), value: user.firstName)
            AccountInfoItem(title: getString(.email), value: user.email)
            AccountInfoItem(title: getString(.schoolLevel), value: user.schoolLevel)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.horizontal)
    }
}

#Preview {
    NavigationStack {
        AccountView()
            .environmentObject(NavigationCoordinator())
    }
}
