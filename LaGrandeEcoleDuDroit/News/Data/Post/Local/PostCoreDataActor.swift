import CoreData

actor PostCoreDataActor {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getPosts() async throws -> [LocalPost] {
        try await context.perform {
            let fetchRequest = LocalPost.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(
                key: PostField.Local.postDate,
                ascending: false
            )]
            
            return try self.context.fetch(fetchRequest)
        }
    }
    
    func getPost(postId: String) async throws -> LocalPost? {
        try await context.perform {
            let fetchRequest = LocalPost.fetchRequest()
            fetchRequest.predicate = NSPredicate(
                format: "%K == %@",
                PostField.Local.postId, postId
            )
            fetchRequest.fetchLimit = 1
            
            return try self.context.fetch(fetchRequest).first
        }
    }
    
    func upsertLocalPost(post: Post) async throws {
        try await context.perform {
            let request = LocalPost.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %@",
                PostField.Local.postId, post.id
            )
            
            let localPost = try self.context.fetch(request).first
            guard localPost?.equals(post) != true else {
                return
            }
            
            if localPost != nil {
                localPost?.modify(post: post)
            } else {
                let newLocalPost = LocalPost(context: self.context)
                newLocalPost.modify(post: post)
            }
            
            try self.context.save()
        }
    }
    
    func delete(postId: String) async throws {
        try await context.perform {
            let request = LocalPost.fetchRequest()
            request.predicate = NSPredicate(
                format: "%K == %@",
                PostField.Local.postId, postId
            )
            
            try self.context.fetch(request).first.map {
                self.context.delete($0)
            }
            
            try self.context.save()
        }
    }
}
