protocol SingleUiEvent {}

struct SuccessEvent: SingleUiEvent {
    let message: String? = nil
}

struct ErrorEvent: SingleUiEvent {
    let message: String
}

extension ErrorEvent {
    init(messages: Set<String>) {
        self.message = messages.joined(separator: "\n")
    }
}
