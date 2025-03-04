enum NewsScreen: Screen {
    case readAnnouncement(_ announcement: Announcement)
    case editAnnouncement(_ announcement: Announcement)
    case createAnnouncement
}
