enum AnnouncementScreenState {
    case initial
    case loading
    case success
    case updated
    case deleted
    case error(message: String)
}
