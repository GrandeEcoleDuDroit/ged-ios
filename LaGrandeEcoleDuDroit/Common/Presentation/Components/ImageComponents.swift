import SwiftUI

struct CacheAsyncImage: View {
    let url: String
    var width: CGFloat?
    var height: CGFloat?
    
    @State private var phase: CachedImagePhase = .empty
    
    var body: some View {
        Group {
            switch phase {
                case .empty:
                    LoadingImage()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .frame(width: width, height: height)
                    
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .frame(width: width, height: height)
                    
                case .failure:
                    ErrorImage()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .frame(width: width, height: height)
            }
        }
        .onAppear {
            if phase.type != .successType {
                Task {
                    await loadImage(url: url)
                }
            }
        }
        .onChange(of: url) { newUrl in
            Task {
                await loadImage(url: newUrl)
            }
        }
    }
    
    private func loadImage(url: String) async {
        guard let url = URL(string: url) else {
            phase = .failure
            return
        }
        
        let request = URLRequest(url: url)
        
        if let cachedResponse = URLCache.shared.cachedResponse(for: request),
           let cachedImage = UIImage(data: cachedResponse.data) {
            await MainActor.run {
                self.phase = .success(Image(uiImage: cachedImage))
            }
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            let cachedData = CachedURLResponse(response: response, data: data)
            URLCache.shared.storeCachedResponse(cachedData, for: request)
            
            if let uiImage = UIImage(data: data) {
                await MainActor.run {
                    self.phase = .success(Image(uiImage: uiImage))
                }
            }
        } catch {
            await MainActor.run {
                self.phase = .failure
            }
        }
    }
}

private enum CachedImagePhase {
    case empty
    case success(Image)
    case failure
    
    var type: PhaseType {
        switch self {
            case .empty: .emptyType
            case .success: .successType
            case .failure: .failureType
        }
    }
    
    enum PhaseType: Int {
        case emptyType = 0
        case successType = 1
        case failureType = 2
    }
}

extension CacheAsyncImage {
    func cacheImageFrame(width: CGFloat, height: CGFloat) -> Self {
        var copy = self
        copy.width = width
        copy.height = height
        return copy
    }
}

struct ProfilePicture: View {
    let url: String?
    var scale: CGFloat = 1.0
   
    var body: some View {
        if let url {
            CacheAsyncImage(url: url)
                .cacheImageFrame(
                    width: Dimens.defaultImageSize * scale,
                    height: Dimens.defaultImageSize * scale
                )
                .clipShape(.circle)
        } else {
            DefaultProfilePicture(scale: scale)
        }
    }
}

struct ProfilePictureImage: View {
    let image: Image
    var scale: CGFloat = 1.0
    
    var body: some View {
        image
            .resizable()
            .scaledToFill()
            .frame(
                width: Dimens.defaultImageSize * scale,
                height: Dimens.defaultImageSize * scale
            )
            .clipShape(.circle)
    }
}

private struct DefaultProfilePicture: View {
    var scale: CGFloat = 1.0
    
    var body: some View {
        Image(ImageResource.defaultProfilePicture)
            .resizable()
            .scaledToFill()
            .frame(
                width: Dimens.defaultImageSize * scale,
                height: Dimens.defaultImageSize * scale
            )
            .clipShape(.circle)
    }
}

private struct LoadingImage: View {
    
    var body: some View {
        Color.imageLoadingBackground
            .overlay {
                ProgressView()
            }
    }
}

private struct ErrorImage: View {
    
    var body: some View {
        Color.imageLoadingBackground
    }
}

#Preview {
    ScrollView {
        VStack(spacing: Dimens.mediumPadding) {
            CacheAsyncImage(url: "https://cdn.britannica.com/16/234216-050-C66F8665/beagle-hound-dog.jpg")
                .cacheImageFrame(width: 200, height: 120)
            Text("Simple async image").font(.caption)
            
            LoadingImage()
                .frame(width: 100, height: 100)
            Text("Loading image").font(.caption)
            
            ErrorImage()
                .frame(width: 100, height: 100)
            Text("Error image").font(.caption)
            
            ProfilePicture(
                url: "https://img.freepik.com/premium-vector/male-avatar-flat-icon-design-vector-illustration_549488-103.jpg",
                scale: 1
            )
            Text("Profile picture").font(.caption)
            
            DefaultProfilePicture()
            Text("Default profile picture").font(.caption)
        }
        .frame(maxWidth: .infinity)
    }
}
