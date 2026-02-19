import Foundation

struct Post: Copying, Hashable {
    let id: String
    let title: String
    var content: String
    let link: String
    let source: PostSource
    let date: Date
    let state: PostState
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    enum PostSource: Int, Codable {
        case linkedin = 1
        case instagram = 2
        case blogLlm = 3
        case unknown
        
        var label: String {
            switch self {
                case .linkedin: "Linkedin"
                case .instagram: "Instagram"
                case .blogLlm: "Blog LLM"
                case .unknown: ""
            }
        }
    }
    
    enum PostState: Hashable, Identifiable {
        case draft
        case publishing(imagePaths: [String] = [])
        case published(imageUrls: [String] = [])
        case error(imagePaths: [String] = [])

        var type: StateType {
            switch self {
                case .draft: .draftType
                case .publishing: .publishingType
                case .published: .publishedType
                case .error: .errorType
            }
        }
        
        var id: Int {
            switch self {
                case .draft: 0
                case .publishing: 1
                case .published: 2
                case .error: 3
            }
        }
        
        var imageReferenceValues: [String] {
            switch self {
                case .draft: []
                case let .publishing(imagePaths: paths): paths
                case let .published(imageUrls: urls): urls
                case let .error(imagePaths: paths): paths
            }
        }
        
        func resolveImagePaths() -> [String] {
            switch self {
                case let .publishing(imagePaths: paths): paths
                case let .error(imagePaths: paths): paths
                default: []
            }
        }
        
        enum StateType: String {
            case draftType = "DRAFT"
            case publishingType = "PUBLISHING"
            case publishedType = "PUBLISHED"
            case errorType = "ERROR"
        }
    }
}
