import Foundation

private let calendar = Calendar.current
private let currentDate = Date.now

let messageFixture = Message(
    id: "1",
    content: "Hi, how are you ?",
    date: Date.now,
    isRead: true
)

let messagesFixture = [
    Message(
        id: "2",
        content: "Hi, how are you ?",
        date: calendar.date(byAdding: .minute, value: -10, to: currentDate) ?? currentDate,
        isRead: true
    ),
    Message(
        id: "3",
        content: "Fine, and you ?",
        date: calendar.date(byAdding: .minute, value: -5, to: currentDate) ?? currentDate,
        isRead: true
    ),
    Message(
        id: "4",
        content: "Fine, thanks !",
        date: calendar.date(byAdding: .minute, value: -2, to: currentDate) ?? currentDate,
        isRead: true
    ),
    Message(
        id: "5",
        content: "Great !",
        date: calendar.date(byAdding: .minute, value: -1, to: currentDate) ?? currentDate,
        isRead: true
    ),
    Message(
        id: "6",
        content: "Ok, see you later !",
        date: currentDate,
        isRead: false
    )
]
