enum ConversationError: Error {
    case notFound
    case createFailed
    case upsertFailed
    case deleteFailed
}
