import Foundation

private let calendar = Calendar.current
private let currentDate = Date()

let announcementFixture = Announcement(
    id: "1",
    title: "Rappel : Visite de cabinet le 23/03.",
    content: "Nous vous informons que la visite de votre " +
    "cabinet médical est programmée pour le 23 mars. " +
    "Cette visite a pour but de s'assurer que toutes les normes de sécurité " +
    "et de conformité sont respectées, ainsi que de vérifier l'état général " +
    "des installations et des équipements médicaux." +
    "Nous vous recommandons de préparer tous les documents nécessaires et " +
    "de veiller à ce que votre personnel soit disponible pour répondre " +
    "à d'éventuelles questions ou fournir des informations supplémentaires. " +
    "Une préparation adéquate permettra de garantir que la visite se déroule " +
    "sans heurts et de manière efficace. N'hésitez pas à nous contacter si " +
    "vous avez des questions ou si vous avez besoin de plus amples informations " +
    "avant la date prévue",
    date: calendar.date(from : DateComponents(year: 2024, month: 10, day: 9)) ?? currentDate,
    author: userFixture,
    state: .published
)

let announcementsFixture = [
    Announcement(
        id: "1",
        title: "First announcement",
        content: "Hi this is my first announcement",
        date: currentDate, author: userFixture,
        state: .published
    ),
    Announcement(
        id: "2",
        title: "Second announcement",
        content: "Hi this is my second announcement",
        date: calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate,
        author:userFixture,
        state: .published
    ),
    Announcement(
        id: "3",
        title: "Third announcement",
        content: "Hi this is my third announcement",
        date: calendar.date(byAdding: .day, value: -3, to: currentDate) ?? currentDate,
        author: userFixture,
        state: .published
    ),
    Announcement(
        id: "4",
        content: "Hi this is my fourth announcement",
        date: calendar.date(byAdding: .weekOfMonth, value: -1, to: currentDate) ?? currentDate,
        author:userFixture,
        state: .published
    ),
    Announcement(
        id: "5",
        content: "Hi this is my fifth announcement",
        date: calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate,
        author: userFixture,
        state: .published
    ),
    Announcement(
        id: "6",
        content: "Hi this is my sixth announcement",
        date: calendar.date(byAdding: .year, value: -1, to: currentDate) ?? currentDate,
        author: userFixture,
        state: .published
    ),
]
