import Testing
import Foundation
import Combine

@testable import ItsCloudy

class RecreatePostUseCaseTest {
    @Test
    func recreatePostUseCase_should_create_post_with_publishing_state_and_image_paths() async {
        // Given
        let imagePaths = ["imagePaths"]
        let post = postFixture.copy { $0.state = .error(imagePaths: imagePaths) }
        let postRepositoryTest = PostRepositoryTest()

        // When
        let useCase = RecreatePostUseCase(
            postRepository: postRepositoryTest,
            imageRepository: MockImageRepository()
        )
        await useCase.execute(post: post)

        // Then
        #expect(postRepositoryTest.createdPostState?.type == .publishingType)
        let pathsResult: [String] = if case let .publishing(paths) = postRepositoryTest.createdPostState {
            paths
        } else {
            []
        }
        #expect(pathsResult == imagePaths)
    }
    
    @Test
    func recreatePostUseCase_should_update_post_state_to_published_with_image_paths_when_success() async {
        // Given
        let imagePaths = ["imagePaths"]
        let post = postFixture.copy { $0.state = .error(imagePaths: imagePaths) }
        let postRepositoryTest = PostRepositoryTest()

        // When
        let useCase = RecreatePostUseCase(
            postRepository: postRepositoryTest,
            imageRepository: MockImageRepository()
        )
        await useCase.execute(post: post)
        
        // Then
        #expect(postRepositoryTest.updatedPostState?.type == .publishedType)
        
        let pathsResult: [String] = if case let .published(paths) = postRepositoryTest.updatedPostState {
            paths
        } else {
            []
        }
        #expect(pathsResult == imagePaths)
    }
    
    @Test
    func recreatePostUseCase_should_update_state_to_error_when_exception_occured() async {
        // Given
        let imagePaths = ["imagePaths"]
        let post = postFixture.copy { $0.state = .error(imagePaths: imagePaths) }
        let createPostException = CreatePostThrowsException()
        
        // When
        let useCase = RecreatePostUseCase(
            postRepository: createPostException,
            imageRepository: MockImageRepository()
        )
        await useCase.execute(post: post)
        
        // Then
        #expect(createPostException.updatedPostState?.type == .errorType)
        let pathsResult: [String] = if case let .error(paths) = createPostException.updatedPostState {
            paths
        } else {
            []
        }
        #expect(pathsResult == imagePaths)
    }
}

private class PostRepositoryTest: MockPostRepository {
    var createdPostState: Post.PostState?
    var updatedPostState: Post.PostState?
    var transmittedImageFileData: [FileData] = []
    
    override func createPost(post: Post, imageFileData: [FileData]) async throws {
        createdPostState = post.state
        transmittedImageFileData = imageFileData
    }
    
    override func upsertLocalPost(post: Post) async throws {
        updatedPostState = post.state
    }
}

private class ImageRepositoryTest: MockImageRepository {
    let givenImageData: Data
    
    init(givenImageData: Data) {
        self.givenImageData = givenImageData
    }

    override func getLocalImage(imagePath: String) async throws -> Data? {
        givenImageData
    }
}

private class CreatePostThrowsException: MockPostRepository {
    var updatedPostState: Post.PostState?

    override func createPost(post: Post, imageFileData: [FileData]) async throws {
        throw NSError(domain: "", code: 0, userInfo: nil)
    }
    
    override func upsertLocalPost(post: Post) async throws {
        updatedPostState = post.state
    }
}
