enum ConversationError: Error {
    case notFound
    case createFailed
    case upsertFailed
    case deleteFailed
}

enum MessageError: Error {
    case createMessageError
    case updateMessageError
    case upsertMessageError
    case notFoundError
}
