import Foundation

private let calendar = Calendar.current
private let currentDate = Date.now

let announcementFixture = Announcement(
    id: 1,
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
    author: userFixture
)

let announcementsFixture = [
    Announcement(id: 1, content: "First announcement", date: currentDate, author: userFixture),
    Announcement(id: 2, content: "Second announcement", date: calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate, author:userFixture),
    Announcement(id: 3, content: "Third announcement", date: calendar.date(byAdding: .day, value: -3, to: currentDate) ?? currentDate, author: userFixture),
    Announcement(id: 4, content: "Fourth announcement", date: calendar.date(byAdding: .weekOfMonth, value: -1, to: currentDate) ?? currentDate, author:userFixture),
    Announcement(id: 5, content: "Fifth announcement", date: calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate, author: userFixture),
    Announcement(id: 6, content: "Sixth announcement", date: calendar.date(byAdding: .year, value: -1, to: currentDate) ?? currentDate, author: userFixture),
]
