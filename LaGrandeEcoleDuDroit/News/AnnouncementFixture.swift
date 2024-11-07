import Foundation

let announcementFixture = Announcement(
    id: 1,
    content: "First announcement",
    date: Date.now,
    author: userFixture
)

let announcementsFixture = [
    Announcement(id: 1, content: "First announcement", date: Date.now, author: userFixture),
    Announcement(id: 2, content: "Second announcement", date: Date.now, author:userFixture),
    Announcement(id: 3, content: "Third announcement", date: Date.now, author: userFixture),
    Announcement(id: 4, content: "Fourth announcement", date: Date.now, author:userFixture),
    Announcement(id: 5, content: "Fifth announcement", date: Date.now, author: userFixture),
    Announcement(id: 6, content: "Sixth announcement", date: Date.now, author: userFixture),
    Announcement(id: 7, content: "Seventh announcement", date: Date.now, author: userFixture)
]
