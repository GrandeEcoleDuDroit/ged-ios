enum AnnouncementScreenState {
    case idle
    case loading
    case success
    case error(message: String)
}
