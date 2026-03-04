import Testing
import Foundation
import Combine

@testable import ItsCloudy

class CreatePostUseCaseTest {
    @Test
    func createPostUseCase_should_create_local_images_when_image_data_is_not_empty() async {
        // Given
        let post = postFixture
        let testImageRepository = TestImageRepository()
        let imageData = [pngImageDataFixture]
        let useCase = CreatePostUseCase(
            postRepository: MockPostRepository(),
            imageRepository: testImageRepository,
        )
        
        // When
        await useCase.execute(post: post, imageData: imageData)
        
        // Then
        #expect(testImageRepository.localImagePathsCreated.count == imageData.count)
    }
    
    @Test
    func createPostUseCase_should_create_post_with_publishing_state_with_image_path() async {
        // Given
        let post = postFixture
        let testPostRepository = TestPostRepository()
        let imageData = [pngImageDataFixture]
        let useCase = CreatePostUseCase(
            postRepository: testPostRepository,
            imageRepository: TestImageRepository()
        )
        
        // When
        await useCase.execute(post: post, imageData: imageData)

        // Then
        #expect(testPostRepository.createdPostState?.type == .publishingType)
        
        let pathResults: [String] = if case let .publishing(imagePaths) = testPostRepository.createdPostState {
            imagePaths
        } else {
            []
        }
        #expect(pathResults.count == imageData.count)
    }
    
    @Test
    func createPostUseCase_should_upsert_post_with_published_state_when_succeed()  async{
        // Given
        let post = postFixture
        let testPostRepository = TestPostRepository()
        let useCase = CreatePostUseCase(
            postRepository: testPostRepository,
            imageRepository: MockImageRepository()
        )
        
        // When
        await useCase.execute(post: post, imageData: [])
        
        // Then
        #expect(testPostRepository.upsertPostState?.type == .publishedType)
    }
    
    @Test
    func createPostUseCase_should_delete_created_local_images() async {
        // Given
        let post = postFixture
        let testImageRepository = TestImageRepository()
        let imageData = [pngImageDataFixture]
        let useCase = CreatePostUseCase(
            postRepository: MockPostRepository(),
            imageRepository: testImageRepository
        )
        
        // When
        await useCase.execute(post: post, imageData: imageData)
        
        // Then
        #expect(testImageRepository.localImagePathsDeleted.count == imageData.count)
    }
    
    @Test
    func createPostUseCase_should_upsert_post_with_error_state_and_image_paths_when_exception_throwns() async {
        // Given
        let post = postFixture
        let testImageRepository = TestImageRepository()
        let createPostException = CreatePostThrowsException()
        let imageData = [pngImageDataFixture]
        let useCase = CreatePostUseCase(
            postRepository: createPostException,
            imageRepository: testImageRepository
        )
        
        // When
        await useCase.execute(post: post, imageData: imageData)
        
        // Then
        #expect(createPostException.upsertPostState?.type == .errorType)
        
        let pathResults: [String] = if case let .error(imagePaths) = createPostException.upsertPostState {
            imagePaths
        } else {
            []
        }
        #expect(pathResults.count == imageData.count)
    }
}

private class TestImageRepository: MockImageRepository {
    private(set) var localImagePathsCreated: [String] = []
    private(set) var localImagePathsDeleted: [String] = []

    override func createLocalImage(imageData: Data, imagePath: String) async throws {
        localImagePathsCreated.append(imagePath)
    }
    
    override func deleteLocalImage(imagePath: String) async throws {
        localImagePathsDeleted.append(imagePath)
    }
}

private class TestPostRepository: MockPostRepository {
    var createdPostState: Post.PostState?
    var upsertPostState: Post.PostState?
    
    override func createPost(post: Post, imageFileData: [FileData]) async throws {
        createdPostState = post.state
    }
    
    override func upsertLocalPost(post: Post) async throws {
        upsertPostState = post.state
    }
}

private class CreatePostThrowsException: MockPostRepository {
    var upsertPostState: Post.PostState?

    override func createPost(post: Post, imageFileData: [FileData]) async throws {
        throw NSError(domain: "", code: 0, userInfo: nil)
    }
    
    override func upsertLocalPost(post: Post) async throws {
        upsertPostState = post.state
    }
}
