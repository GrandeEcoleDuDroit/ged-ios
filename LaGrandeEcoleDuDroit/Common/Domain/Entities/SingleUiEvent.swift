protocol SingleUiEvent {}

struct SuccessEvent: SingleUiEvent {
    let message: String? = nil
}

struct ErrorEvent: SingleUiEvent {
    let message: String
}
