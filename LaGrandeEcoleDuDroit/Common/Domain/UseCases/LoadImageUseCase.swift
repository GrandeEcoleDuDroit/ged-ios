class LoadImageUseCase {
    private let imageRepository: ImageRepository
    
    init(imageRepository: ImageRepository) {
        self.imageRepository = imageRepository
    }
    
    func execute(url: String) async -> ImagePhase {
        do {
            return if let data = try await imageRepository.loadImage(url: url) {
                .success(data)
            } else {
                .empty
            }
        } catch {
            return .failure
        }
    }
}
