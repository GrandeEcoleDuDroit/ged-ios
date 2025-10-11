import FirebaseFirestore

class BlockedUserApiImpl: BlockedUserApi {
    private let tag = String(describing: BlockedUserApiImpl.self)
    private let blockedUserFirestoreApi: BlockedUserFirestoreApi
    
    init(blockedUserFirestoreApi: BlockedUserFirestoreApi) {
        self.blockedUserFirestoreApi = blockedUserFirestoreApi
    }
    
    func getBlockedUserIds(currentUserId: String) async throws -> Set<String> {
        try await mapFirebaseException(
            block: {  try await blockedUserFirestoreApi.getBlockedUserIds(currentUserId: currentUserId) },
            tag: tag,
            message: "Failed to get blocked user ids from Firestore"
        )
    }
    
    func blockUser(currentUserId: String, userId: String) async throws {
        try await mapFirebaseException(
            block: {  try await blockedUserFirestoreApi.blockUser(currentUserId: currentUserId, userId: userId) },
            tag: tag,
            message: "Failed to block user with Firestore"
        )
    }
    
    func unblockUser(currentUserId: String, userId: String) async throws {
        try await mapFirebaseException(
            block: {  try await blockedUserFirestoreApi.unblockUser(currentUserId: currentUserId, userId: userId) },
            tag: tag,
            message: "Failed to unblock user with Firestore"
        )
    }
}

class BlockedUserFirestoreApi {
    private let blockedUsersCollection: CollectionReference = Firestore.firestore().collection("blockedUsers")
    private let dataKey = "userIds"
    
    func getBlockedUserIds(currentUserId: String) async throws -> Set<String> {
        let userIds = try await blockedUsersCollection.document(currentUserId)
            .getDocument()
            .data()?[dataKey] as? [String] ?? []
        

        return Set(userIds)
    }
    
    func blockUser(currentUserId: String, userId: String) async throws {
        let data = [dataKey: FieldValue.arrayUnion([userId])]
        try await blockedUsersCollection.document(currentUserId).setData(data, merge: true)
    }
    
    func unblockUser(currentUserId: String, userId: String) async throws {
        let data = [dataKey: FieldValue.arrayRemove([userId])]
        try await blockedUsersCollection.document(currentUserId).setData(data, merge: true)
    }
}
